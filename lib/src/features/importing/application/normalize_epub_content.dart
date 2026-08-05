import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/epub_container.dart';
import '../domain/epub_semantic_content.dart';
import '../domain/parsed_epub.dart';
import 'decode_epub_markup.dart';

final class NormalizeEpubContent {
  const NormalizeEpubContent();

  Future<List<EpubSemanticChapter>> call(
    EpubContainer container,
    ParsedEpub book,
  ) async {
    final chapters = <EpubSemanticChapter>[];
    final manifestByPath = <String, EpubManifestItem>{
      for (final item in book.manifest.values) item.path: item,
    };
    for (final spineItem in book.spine) {
      if (spineItem.item.mediaType != 'application/xhtml+xml') {
        throw AppFailure.fromCode(AppErrorCode.epubContentUnsupported);
      }
      try {
        final document = html_parser.parse(
          decodeEpubMarkup(await container.readBytes(spineItem.item.path)),
        );
        final body = document.body;
        if (body == null) {
          throw AppFailure.fromCode(AppErrorCode.epubContentUnsupported);
        }
        final blocks = <EpubSemanticBlock>[];
        for (final node in body.nodes) {
          _appendBlocks(
            node,
            blocks,
            container: container,
            chapterPath: spineItem.item.path,
            manifestByPath: manifestByPath,
          );
        }
        if (blocks.isEmpty) {
          throw AppFailure.fromCode(AppErrorCode.epubContentUnsupported);
        }
        final firstHeading = blocks
            .where((block) => block.kind == EpubBlockKind.heading)
            .firstOrNull;
        chapters.add(
          EpubSemanticChapter(
            manifestId: spineItem.item.id,
            sourcePath: spineItem.item.path,
            title: firstHeading?.text ?? spineItem.item.id,
            linear: spineItem.linear,
            blocks: List.unmodifiable(blocks),
          ),
        );
      } on AppFailure {
        rethrow;
      } on Object {
        throw AppFailure.fromCode(AppErrorCode.epubContentUnsupported);
      }
    }
    return List.unmodifiable(chapters);
  }

  void _appendBlocks(
    Node node,
    List<EpubSemanticBlock> output, {
    required EpubContainer container,
    required String chapterPath,
    required Map<String, EpubManifestItem> manifestByPath,
    int listDepth = 0,
    bool? ordered,
  }) {
    if (node is Text) {
      final text = _normalizeWhitespace(node.data);
      if (text.isNotEmpty) {
        output.add(
          EpubSemanticBlock.text(kind: EpubBlockKind.paragraph, text: text),
        );
      }
      return;
    }
    if (node is! Element) {
      return;
    }

    final name = node.localName;
    if (_ignoredElements.contains(name)) {
      return;
    }
    if (name == 'hr') {
      output.add(EpubSemanticBlock.divider(sourceId: node.id.nullIfEmpty));
      return;
    }
    if (name == 'img') {
      _appendImage(
        node,
        output,
        container: container,
        chapterPath: chapterPath,
        manifestByPath: manifestByPath,
      );
      return;
    }
    if (name == 'ol' || name == 'ul') {
      for (final child in node.children) {
        _appendBlocks(
          child,
          output,
          container: container,
          chapterPath: chapterPath,
          manifestByPath: manifestByPath,
          listDepth: listDepth + 1,
          ordered: name == 'ol',
        );
      }
      return;
    }
    if (name == 'li') {
      _appendTextBlock(
        node,
        output,
        kind: EpubBlockKind.listItem,
        listDepth: listDepth,
        ordered: ordered,
      );
      for (final child in node.children.where(
        (element) => element.localName == 'ol' || element.localName == 'ul',
      )) {
        _appendBlocks(
          child,
          output,
          container: container,
          chapterPath: chapterPath,
          manifestByPath: manifestByPath,
          listDepth: listDepth,
          ordered: ordered,
        );
      }
      return;
    }
    if (name != null && RegExp(r'^h[1-6]$').hasMatch(name)) {
      _appendTextBlock(
        node,
        output,
        kind: EpubBlockKind.heading,
        headingLevel: int.parse(name.substring(1)),
      );
      return;
    }
    if (name == 'p' || name == 'pre') {
      _appendTextBlock(node, output, kind: EpubBlockKind.paragraph);
      for (final image in node.querySelectorAll('img')) {
        _appendImage(
          image,
          output,
          container: container,
          chapterPath: chapterPath,
          manifestByPath: manifestByPath,
        );
      }
      return;
    }
    if (name == 'blockquote') {
      _appendTextBlock(node, output, kind: EpubBlockKind.quote);
      return;
    }

    for (final child in node.nodes) {
      _appendBlocks(
        child,
        output,
        container: container,
        chapterPath: chapterPath,
        manifestByPath: manifestByPath,
        listDepth: listDepth,
        ordered: ordered,
      );
    }
  }

  void _appendTextBlock(
    Element element,
    List<EpubSemanticBlock> output, {
    required EpubBlockKind kind,
    int? headingLevel,
    int? listDepth,
    bool? ordered,
  }) {
    final builder = _StyledTextBuilder()..appendElement(element);
    final value = builder.build();
    if (value.text.isEmpty) {
      return;
    }
    output.add(
      EpubSemanticBlock.text(
        kind: kind,
        text: value.text,
        sourceId: element.id.nullIfEmpty,
        headingLevel: headingLevel,
        listDepth: listDepth,
        ordered: ordered,
        styleSpans: value.spans,
      ),
    );
  }

  void _appendImage(
    Element element,
    List<EpubSemanticBlock> output, {
    required EpubContainer container,
    required String chapterPath,
    required Map<String, EpubManifestItem> manifestByPath,
  }) {
    final source = element.attributes['src']?.trim();
    if (source == null || source.isEmpty) {
      return;
    }
    final uri = Uri.tryParse(source);
    if (uri == null || uri.hasScheme || uri.hasAuthority) {
      return;
    }
    final path = container.resolvePath(chapterPath, source);
    final item = manifestByPath[path];
    if (item == null || !item.mediaType.startsWith('image/')) {
      return;
    }
    if (!container.contains(path)) {
      throw AppFailure.fromCode(AppErrorCode.epubResourceMissing);
    }
    output.add(
      EpubSemanticBlock.image(
        imagePath: path,
        imageMediaType: item.mediaType,
        altText: element.attributes['alt']?.trim().nullIfEmpty,
        sourceId: element.id.nullIfEmpty,
      ),
    );
  }
}

const _ignoredElements = <String?>{
  'script',
  'style',
  'form',
  'input',
  'button',
  'select',
  'textarea',
  'iframe',
  'object',
  'embed',
  'canvas',
  'audio',
  'video',
  'source',
  'template',
  'noscript',
  'svg',
};

String _normalizeWhitespace(String value) =>
    value.replaceAll(RegExp(r'\s+'), ' ').trim();

final _whitespaceCharacter = RegExp(r'\s');

final class _StyledTextBuilder {
  final StringBuffer _buffer = StringBuffer();
  final List<EpubTextStyleSpan> _spans = <EpubTextStyleSpan>[];
  var _endsWithSpace = false;

  void appendElement(
    Element element, {
    bool bold = false,
    bool italic = false,
  }) {
    final name = element.localName;
    final nextBold = bold || name == 'strong' || name == 'b';
    final nextItalic = italic || name == 'em' || name == 'i';
    final start = _buffer.length;
    for (final child in element.nodes) {
      if (child is Text) {
        _appendText(child.data);
      } else if (child is Element && child.localName != 'img') {
        if (child.localName == 'br') {
          _appendText(' ');
        } else if (!_ignoredElements.contains(child.localName) &&
            child.localName != 'ol' &&
            child.localName != 'ul') {
          appendElement(child, bold: nextBold, italic: nextItalic);
        }
      }
    }
    final end = _buffer.length;
    if (end > start &&
        (nextBold || nextItalic) &&
        (name == 'strong' || name == 'b' || name == 'em' || name == 'i')) {
      _spans.add(
        EpubTextStyleSpan(
          start: start,
          end: end,
          bold: nextBold,
          italic: nextItalic,
        ),
      );
    }
  }

  void _appendText(String value) {
    for (final codePoint in value.runes) {
      final character = String.fromCharCode(codePoint);
      if (_whitespaceCharacter.hasMatch(character)) {
        if (_buffer.length > 0 && !_endsWithSpace) {
          _buffer.write(' ');
          _endsWithSpace = true;
        }
      } else {
        _buffer.write(character);
        _endsWithSpace = false;
      }
    }
  }

  _StyledText build() {
    final raw = _buffer.toString();
    final text = raw.trimRight();
    return _StyledText(
      text,
      List.unmodifiable(
        _spans
            .map(
              (span) => EpubTextStyleSpan(
                start: span.start.clamp(0, text.length),
                end: span.end.clamp(0, text.length),
                bold: span.bold,
                italic: span.italic,
              ),
            )
            .where((span) => span.end > span.start),
      ),
    );
  }
}

final class _StyledText {
  const _StyledText(this.text, this.spans);
  final String text;
  final List<EpubTextStyleSpan> spans;
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
