import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../library/domain/media_item.dart' as domain;
import '../domain/content_unit.dart' as domain;
import '../domain/novel_reader_repository.dart';
import '../domain/reader_book.dart';

final class DartIoNovelReaderRepository implements NovelReaderRepository {
  DartIoNovelReaderRepository(
    this.database,
    this.derivedTxtRoot, {
    Directory? derivedEpubRoot,
  }) : derivedEpubRoot = derivedEpubRoot ?? derivedTxtRoot;

  final AppDatabase database;
  final Directory derivedTxtRoot;
  final Directory derivedEpubRoot;
  final Map<String, String> _textCache = {};

  @override
  Future<ReaderBook?> loadBook(String mediaItemId) async {
    final media = await (database.select(
      database.mediaItems,
    )..where((row) => row.id.equals(mediaItemId))).getSingleOrNull();
    if (media == null) return null;
    final units =
        await (database.select(database.contentUnits)
              ..where((row) => row.mediaItemId.equals(mediaItemId))
              ..orderBy([(row) => OrderingTerm.asc(row.orderIndex)]))
            .get();
    return ReaderBook(
      mediaItem: domain.MediaItem(
        id: media.id,
        mediaType: domain.MediaType.fromStorageValue(media.mediaType),
        title: media.title,
        subtitle: media.subtitle,
        creator: media.creator,
        description: media.description,
        coverRef: media.coverRef,
        createdAt: media.createdAt,
        updatedAt: media.updatedAt,
      ),
      chapters: [for (final unit in units) _mapUnit(unit)],
    );
  }

  @override
  Future<ReaderChapter> readChapter(domain.ContentUnit unit) async {
    if (unit.contentRef.startsWith('epub/')) {
      return _readEpubChapter(unit);
    }
    final file = _resolveContentRef(unit.contentRef);
    final text =
        _textCache[unit.contentRef] ??
        utf8.decode(await file.readAsBytes(), allowMalformed: false);
    _textCache[unit.contentRef] = text;
    final offsets = _parseLocator(unit.sourceLocator, text.length);
    final complete = text.substring(offsets.start, offsets.end);
    if (sha256.convert(utf8.encode(complete)).toString() != unit.contentHash) {
      throw const FormatException('content_hash_mismatch');
    }
    return ReaderChapter(
      unit: unit,
      text: text.substring(offsets.body, offsets.end),
    );
  }

  Future<ReaderChapter> _readEpubChapter(domain.ContentUnit unit) async {
    final file = _resolveEpubChapterRef(unit.contentRef);
    final bytes = await file.readAsBytes();
    if (sha256.convert(bytes).toString() != unit.contentHash) {
      throw const FormatException('content_hash_mismatch');
    }
    final value = jsonDecode(utf8.decode(bytes, allowMalformed: false));
    if (value is! Map<String, dynamic> ||
        value['schema'] != 'epub-derived-v1' ||
        value['blocks'] is! List<dynamic>) {
      throw const FormatException('invalid_epub_chapter');
    }
    final blocks = <ReaderBlock>[];
    for (final value in value['blocks'] as List<dynamic>) {
      blocks.add(_parseEpubBlock(value, unit.mediaItemId));
    }
    if (blocks.isEmpty) {
      throw const FormatException('empty_epub_chapter');
    }
    return ReaderChapter(
      unit: unit,
      text: blocks
          .where((block) => block.text != null)
          .map((block) => block.text!)
          .join('\n\n'),
      blocks: List.unmodifiable(blocks),
    );
  }

  ReaderBlock _parseEpubBlock(Object? value, String mediaItemId) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('invalid_epub_block');
    }
    final kindName = value['kind'];
    final kind = ReaderBlockKind.values
        .where((candidate) => candidate.name == kindName)
        .firstOrNull;
    if (kind == null) throw const FormatException('invalid_epub_block_kind');
    final text = value['text'];
    final spansValue = value['styleSpans'];
    if (text != null && text is! String ||
        spansValue != null && spansValue is! List<dynamic>) {
      throw const FormatException('invalid_epub_block');
    }
    String? imagePath;
    if (kind == ReaderBlockKind.image) {
      final imageRef = value['imageRef'];
      if (imageRef is! String) {
        throw const FormatException('invalid_epub_image_ref');
      }
      imagePath = _resolveEpubImageRef(imageRef, mediaItemId).path;
    }
    final spans = <ReaderTextStyleSpan>[];
    for (final span in spansValue as List<dynamic>? ?? const []) {
      if (span is! Map<String, dynamic> ||
          span['start'] is! int ||
          span['end'] is! int ||
          span['bold'] is! bool ||
          span['italic'] is! bool) {
        throw const FormatException('invalid_epub_style_span');
      }
      final start = span['start'] as int;
      final end = span['end'] as int;
      if (text == null || start < 0 || end <= start || end > text.length) {
        throw const FormatException('invalid_epub_style_range');
      }
      spans.add(
        ReaderTextStyleSpan(
          start: start,
          end: end,
          bold: span['bold'] as bool,
          italic: span['italic'] as bool,
        ),
      );
    }
    return ReaderBlock(
      kind: kind,
      text: text as String?,
      headingLevel: value['headingLevel'] as int?,
      listDepth: value['listDepth'] as int?,
      ordered: value['ordered'] as bool?,
      imagePath: imagePath,
      altText: value['altText'] as String?,
      styleSpans: List.unmodifiable(spans),
    );
  }

  File _resolveContentRef(String contentRef) {
    final parts = contentRef.split('/');
    if (parts.length != 2 ||
        parts.first != 'content' ||
        !RegExp(r'^[A-Za-z0-9_-]+\.txt$').hasMatch(parts.last)) {
      throw const FormatException('invalid_content_ref');
    }
    return File(
      '${derivedTxtRoot.path}${Platform.pathSeparator}content'
      '${Platform.pathSeparator}${parts.last}',
    );
  }

  File _resolveEpubChapterRef(String contentRef) {
    final match = RegExp(
      r'^epub/([A-Za-z0-9_-]+)/chapters/([0-9]{5}\.json)$',
    ).firstMatch(contentRef);
    if (match == null) throw const FormatException('invalid_content_ref');
    return File(
      '${derivedEpubRoot.path}${Platform.pathSeparator}content'
      '${Platform.pathSeparator}${match.group(1)}'
      '${Platform.pathSeparator}chapters'
      '${Platform.pathSeparator}${match.group(2)}',
    );
  }

  File _resolveEpubImageRef(String imageRef, String mediaItemId) {
    final match = RegExp(
      r'^epub/([A-Za-z0-9_-]+)/images/'
      r'([a-f0-9]{64}\.(?:jpg|png|gif|webp|bmp))$',
    ).firstMatch(imageRef);
    if (match == null || match.group(1) != mediaItemId) {
      throw const FormatException('invalid_epub_image_ref');
    }
    return File(
      '${derivedEpubRoot.path}${Platform.pathSeparator}content'
      '${Platform.pathSeparator}$mediaItemId'
      '${Platform.pathSeparator}images'
      '${Platform.pathSeparator}${match.group(2)}',
    );
  }

  _Offsets _parseLocator(String locator, int textLength) {
    final match = RegExp(r'^txt-v1:(\d+):(\d+):(\d+)$').firstMatch(locator);
    if (match == null) throw const FormatException('invalid_locator');
    final start = int.parse(match.group(1)!);
    final body = int.parse(match.group(2)!);
    final end = int.parse(match.group(3)!);
    if (start > body || body > end || end > textLength) {
      throw const FormatException('invalid_locator_range');
    }
    return _Offsets(start, body, end);
  }

  domain.ContentUnit _mapUnit(ContentUnit unit) => domain.ContentUnit(
    id: unit.id,
    mediaItemId: unit.mediaItemId,
    unitType: domain.ContentUnitType.fromStorageValue(unit.unitType),
    title: unit.title,
    orderIndex: unit.orderIndex,
    contentRef: unit.contentRef,
    sourceLocator: unit.sourceLocator,
    contentHash: unit.contentHash,
  );
}

final class _Offsets {
  const _Offsets(this.start, this.body, this.end);
  final int start;
  final int body;
  final int end;
}
