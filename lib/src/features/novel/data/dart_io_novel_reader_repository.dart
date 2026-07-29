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
  DartIoNovelReaderRepository(this.database, this.derivedRoot);

  final AppDatabase database;
  final Directory derivedRoot;
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

  File _resolveContentRef(String contentRef) {
    final parts = contentRef.split('/');
    if (parts.length != 2 ||
        parts.first != 'content' ||
        !RegExp(r'^[A-Za-z0-9_-]+\.txt$').hasMatch(parts.last)) {
      throw const FormatException('invalid_content_ref');
    }
    return File(
      '${derivedRoot.path}${Platform.pathSeparator}content'
      '${Platform.pathSeparator}${parts.last}',
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
