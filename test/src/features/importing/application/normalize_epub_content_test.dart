import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/application/normalize_epub_content.dart';
import 'package:mirascope/src/features/importing/application/parse_epub_package.dart';
import 'package:mirascope/src/features/importing/data/dart_io_epub_container.dart';
import 'package:mirascope/src/features/importing/domain/epub_semantic_content.dart';
import 'package:mirascope/src/features/importing/domain/parsed_epub.dart';

import '../../../../support/epub_test_fixture.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'mirascope-epub-normalizer-',
    );
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  for (final version in TestEpubVersion.values) {
    test('normalizes the ${version.name} fixture into text blocks', () async {
      final path = await _writeBytes(
        temporaryDirectory,
        buildTestEpub(version),
      );
      final container = await DartIoEpubContainer.open(path);
      addTearDown(container.close);
      final book = await const ParseEpubPackage()(container);

      final chapters = await const NormalizeEpubContent()(container, book);

      expect(chapters, hasLength(1));
      expect(chapters.single.title, '第一章');
      expect(chapters.single.blocks.map((block) => block.kind), <EpubBlockKind>[
        EpubBlockKind.heading,
        EpubBlockKind.paragraph,
      ]);
      expect(chapters.single.blocks.last.text, contains('mirascope'));
    });
  }

  test(
    'preserves semantic order, inline emphasis, lists, quotes, and image',
    () async {
      final fixture = await _openBook(
        temporaryDirectory,
        chapter: _richChapter,
        image: <int>[1, 2, 3],
      );
      addTearDown(fixture.container.close);

      final chapters = await const NormalizeEpubContent()(
        fixture.container,
        fixture.book,
      );
      final blocks = chapters.single.blocks;

      expect(blocks.map((block) => block.kind), <EpubBlockKind>[
        EpubBlockKind.heading,
        EpubBlockKind.paragraph,
        EpubBlockKind.listItem,
        EpubBlockKind.listItem,
        EpubBlockKind.quote,
        EpubBlockKind.divider,
        EpubBlockKind.image,
        EpubBlockKind.paragraph,
      ]);
      expect(blocks[1].text, '普通 粗体 斜体 文本');
      expect(blocks[1].styleSpans, hasLength(2));
      expect(blocks[1].styleSpans.first.bold, isTrue);
      expect(blocks[1].styleSpans.last.italic, isTrue);
      expect(
        blocks[1].text!.substring(
          blocks[1].styleSpans.first.start,
          blocks[1].styleSpans.first.end,
        ),
        '粗体',
      );
      expect(
        blocks[1].text!.substring(
          blocks[1].styleSpans.last.start,
          blocks[1].styleSpans.last.end,
        ),
        '斜体',
      );
      expect(blocks[2].ordered, isTrue);
      expect(blocks[2].listDepth, 1);
      expect(blocks[3].ordered, isFalse);
      expect(blocks[3].listDepth, 2);
      expect(blocks[6].imagePath, 'OEBPS/images/cover.png');
      expect(blocks[6].altText, '封面');
      expect(blocks.last.text, '保留链接文字');
      expect(
        blocks.expand((block) => <String>[block.text ?? '']),
        isNot(contains('恶意')),
      );
    },
  );

  test('remote images are ignored and never become resources', () async {
    final fixture = await _openBook(
      temporaryDirectory,
      chapter:
          '<html><body><h1>标题</h1><img src="https://example.com/tracker.png"/><p>正文</p></body></html>',
    );
    addTearDown(fixture.container.close);

    final chapters = await const NormalizeEpubContent()(
      fixture.container,
      fixture.book,
    );

    expect(
      chapters.single.blocks.where(
        (block) => block.kind == EpubBlockKind.image,
      ),
      isEmpty,
    );
    expect(chapters.single.blocks.last.text, '正文');
  });

  test('missing declared local image fails safely', () async {
    final fixture = await _openBook(
      temporaryDirectory,
      chapter:
          '<html><body><h1>标题</h1><img src="images/cover.png"/></body></html>',
      declareImage: true,
    );
    addTearDown(fixture.container.close);

    await expectLater(
      const NormalizeEpubContent()(fixture.container, fixture.book),
      throwsCode('epub_resource_missing'),
    );
  });

  test('unsafe local image path remains an unsafe-path failure', () async {
    final fixture = await _openBook(
      temporaryDirectory,
      chapter:
          '<html><body><h1>标题</h1><img src="../../secret.png"/></body></html>',
    );
    addTearDown(fixture.container.close);

    await expectLater(
      const NormalizeEpubContent()(fixture.container, fixture.book),
      throwsCode('epub_unsafe_path'),
    );
  });

  test('empty or non-XHTML reading content is rejected', () async {
    final emptyFixture = await _openBook(
      temporaryDirectory,
      chapter: '<html><body><script>bad()</script></body></html>',
    );
    addTearDown(emptyFixture.container.close);
    await expectLater(
      const NormalizeEpubContent()(emptyFixture.container, emptyFixture.book),
      throwsCode('epub_content_unsupported'),
    );

    final item = emptyFixture.book.spine.single.item;
    final unsupportedBook = ParsedEpub(
      version: emptyFixture.book.version,
      packagePath: emptyFixture.book.packagePath,
      title: emptyFixture.book.title,
      authors: emptyFixture.book.authors,
      manifest: <String, EpubManifestItem>{
        item.id: EpubManifestItem(
          id: item.id,
          path: item.path,
          mediaType: 'image/svg+xml',
          properties: const <String>{},
        ),
      },
      spine: <EpubSpineItem>[
        EpubSpineItem(
          item: EpubManifestItem(
            id: item.id,
            path: item.path,
            mediaType: 'image/svg+xml',
            properties: const <String>{},
          ),
          linear: true,
        ),
      ],
      navigation: const [],
    );
    await expectLater(
      const NormalizeEpubContent()(emptyFixture.container, unsupportedBook),
      throwsCode('epub_content_unsupported'),
    );
  });

  test('skips an SVG-only cover before readable XHTML content', () async {
    final fixture = await _openBookWithSvgCover(temporaryDirectory);
    addTearDown(fixture.container.close);

    final chapters = await const NormalizeEpubContent()(
      fixture.container,
      fixture.book,
    );

    expect(chapters, hasLength(1));
    expect(chapters.single.title, '正文');
    expect(chapters.single.sourcePath, 'OEBPS/chapter.xhtml');
  });

  test('UTF-16 XHTML is decoded before normalization', () async {
    final fixture = await _openBook(
      temporaryDirectory,
      chapterBytes: _utf16Le('<html><body><h1>章节</h1><p>正文</p></body></html>'),
    );
    addTearDown(fixture.container.close);

    final chapters = await const NormalizeEpubContent()(
      fixture.container,
      fixture.book,
    );

    expect(chapters.single.title, '章节');
    expect(chapters.single.blocks.last.text, '正文');
  });
}

Future<_OpenedBook> _openBook(
  Directory directory, {
  String? chapter,
  List<int>? chapterBytes,
  List<int>? image,
  bool declareImage = false,
}) async {
  final archive = Archive()
    ..add(ArchiveFile.string('mimetype', 'application/epub+zip'))
    ..add(ArchiveFile.string('META-INF/container.xml', _containerXml))
    ..add(
      ArchiveFile.string(
        'OEBPS/content.opf',
        _packageXml(includeImage: image != null || declareImage),
      ),
    )
    ..add(
      chapterBytes == null
          ? ArchiveFile.string('OEBPS/chapter.xhtml', chapter!)
          : ArchiveFile.bytes('OEBPS/chapter.xhtml', chapterBytes),
    );
  if (image != null) {
    archive.add(ArchiveFile.bytes('OEBPS/images/cover.png', image));
  }
  final path = await _writeBytes(directory, ZipEncoder().encodeBytes(archive));
  final container = await DartIoEpubContainer.open(path);
  final book = await const ParseEpubPackage()(container);
  return _OpenedBook(container, book);
}

Future<_OpenedBook> _openBookWithSvgCover(Directory directory) async {
  final archive = Archive()
    ..add(ArchiveFile.string('mimetype', 'application/epub+zip'))
    ..add(ArchiveFile.string('META-INF/container.xml', _containerXml))
    ..add(ArchiveFile.string('OEBPS/content.opf', _packageWithSvgCoverXml))
    ..add(ArchiveFile.string('OEBPS/cover.xhtml', _svgCoverChapter))
    ..add(
      ArchiveFile.string(
        'OEBPS/chapter.xhtml',
        '<html><body><h1>正文</h1><p>可读内容</p></body></html>',
      ),
    );
  final path = await _writeBytes(directory, ZipEncoder().encodeBytes(archive));
  final container = await DartIoEpubContainer.open(path);
  final book = await const ParseEpubPackage()(container);
  return _OpenedBook(container, book);
}

Future<String> _writeBytes(Directory directory, List<int> bytes) async {
  final file = File(
    '${directory.path}${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}.epub',
  );
  await file.writeAsBytes(bytes);
  return file.path;
}

Matcher throwsCode(String code) =>
    throwsA(isA<AppFailure>().having((failure) => failure.code, 'code', code));

List<int> _utf16Le(String value) => <int>[
  0xff,
  0xfe,
  for (final unit in value.codeUnits) ...<int>[unit & 0xff, unit >> 8],
];

final class _OpenedBook {
  const _OpenedBook(this.container, this.book);
  final DartIoEpubContainer container;
  final ParsedEpub book;
}

const _containerXml = '''
<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles>
</container>''';

String _packageXml({required bool includeImage}) =>
    '''
<package version="3.0" xmlns="http://www.idpf.org/2007/opf">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:title>测试书</dc:title></metadata>
  <manifest>
    <item id="chapter" href="chapter.xhtml" media-type="application/xhtml+xml"/>
    ${includeImage ? '<item id="cover" href="images/cover.png" media-type="image/png"/>' : ''}
  </manifest>
  <spine><itemref idref="chapter"/></spine>
</package>''';

const _packageWithSvgCoverXml = '''
<package version="3.0" xmlns="http://www.idpf.org/2007/opf">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:title>测试书</dc:title></metadata>
  <manifest>
    <item id="cover" href="cover.xhtml" media-type="application/xhtml+xml"/>
    <item id="chapter" href="chapter.xhtml" media-type="application/xhtml+xml"/>
  </manifest>
  <spine><itemref idref="cover"/><itemref idref="chapter"/></spine>
</package>''';

const _svgCoverChapter = '''
<html xmlns="http://www.w3.org/1999/xhtml">
  <body><svg xmlns="http://www.w3.org/2000/svg"><image href="cover.jpg"/></svg></body>
</html>''';

const _richChapter = '''
<html><head><style>p { color: red; }</style></head><body>
  <h1 id="start">章节标题</h1>
  <p>普通 <strong>粗体</strong> <em>斜体</em> 文本</p>
  <ol><li>第一项<ul><li>子项</li></ul></li></ol>
  <blockquote>引用内容</blockquote><hr/>
  <img src="images/cover.png" alt="封面" onerror="bad()"/>
  <script>恶意</script><iframe src="https://example.com"></iframe>
  <p><a href="https://example.com">保留链接文字</a></p>
</body></html>''';
