import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/features/library/data/drift_media_library_repository.dart';

import '../../../core/database/database_test_support.dart';

final _now = DateTime.utc(2026, 7, 28, 9);

void main() {
  test('active stream excludes archived entries', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(database, id: 'active', title: 'Active');
    await _insertMediaAndLibraryEntry(
      database,
      id: 'archived',
      title: 'Archived',
      archivedAt: _now,
    );

    final items = await repository.watchActiveLibrary().first;

    expect(items.map((item) => item.mediaItem.id).toList(), ['active']);
  });

  test('archive removes an item from the active stream', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(database, id: 'media-1', title: 'Book');
    final iterator = StreamIterator(repository.watchActiveLibrary());
    addTearDown(iterator.cancel);

    await iterator.moveNext();
    expect(iterator.current, hasLength(1));

    await repository.archive('media-1', _now);
    await iterator.moveNext();

    expect(iterator.current, isEmpty);
  });

  test('restore returns the same library entry ID', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(
      database,
      id: 'media-1',
      title: 'Book',
      archivedAt: _now,
    );

    await repository.restore('media-1');
    final entry = await (database.select(
      database.libraryEntries,
    )..where((row) => row.mediaItemId.equals('media-1'))).getSingle();

    expect(entry.id, 'entry-media-1');
    expect(entry.archivedAt, isNull);
  });

  test(
    'results order by lastOpenedAt descending then addedAt descending',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final repository = DriftMediaLibraryRepository(database);
      await _insertMediaAndLibraryEntry(
        database,
        id: 'older-opened',
        title: 'Older opened',
        addedAt: _now.add(const Duration(hours: 1)),
        lastOpenedAt: _now.add(const Duration(hours: 2)),
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'newer-opened',
        title: 'Newer opened',
        addedAt: _now,
        lastOpenedAt: _now.add(const Duration(hours: 3)),
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'newer-unopened',
        title: 'Newer unopened',
        addedAt: _now.add(const Duration(hours: 4)),
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'older-unopened',
        title: 'Older unopened',
        addedAt: _now.add(const Duration(hours: 2)),
      );

      final items = await repository.watchActiveLibrary().first;

      expect(items.map((item) => item.mediaItem.id).toList(), [
        'newer-opened',
        'older-opened',
        'newer-unopened',
        'older-unopened',
      ]);
    },
  );

  test('deleting a media item removes database dependents', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(database, id: 'media-1', title: 'Book');
    await database
        .into(database.contentUnits)
        .insert(
          ContentUnitsCompanion.insert(
            id: 'unit-1',
            mediaItemId: 'media-1',
            unitType: 'chapter',
            title: 'Chapter 1',
            orderIndex: 0,
            contentRef: 'content/unit-1',
            sourceLocator: 'source#chapter-1',
            contentHash: 'hash-1',
          ),
        );
    await database
        .into(database.readingProgressEntries)
        .insert(
          ReadingProgressEntriesCompanion.insert(
            id: 'progress-1',
            mediaItemId: 'media-1',
            contentUnitId: 'unit-1',
            locator: 'paragraph:1',
            fraction: 0.5,
            updatedAt: _now,
            revision: 0,
          ),
        );
    await database
        .into(database.readerPreferences)
        .insert(
          ReaderPreferencesCompanion.insert(
            id: 'preference-1',
            scope: 'mediaItem',
            mediaItemId: const Value('media-1'),
            updatedAt: _now,
          ),
        );
    await database
        .into(database.importRecords)
        .insert(
          ImportRecordsCompanion.insert(
            id: 'import-1',
            mediaItemId: 'media-1',
            sourcePath: 'C:/books/book.txt',
            sourceKind: 'txtFile',
            fileSize: 100,
            fingerprint: 'fingerprint-1',
            status: 'completed',
            createdAt: _now,
          ),
        );

    await repository.deleteApplicationData('media-1');

    expect(await repository.findMediaItem('media-1'), isNull);
    expect(await database.select(database.libraryEntries).get(), isEmpty);
    expect(await database.select(database.contentUnits).get(), isEmpty);
    expect(
      await database.select(database.readingProgressEntries).get(),
      isEmpty,
    );
    expect(await database.select(database.readerPreferences).get(), isEmpty);
    expect(await database.select(database.importRecords).get(), isEmpty);
  });
}

Future<void> _insertMediaAndLibraryEntry(
  AppDatabase database, {
  required String id,
  required String title,
  DateTime? addedAt,
  DateTime? lastOpenedAt,
  DateTime? archivedAt,
}) async {
  await database
      .into(database.mediaItems)
      .insert(
        MediaItemsCompanion.insert(
          id: id,
          mediaType: 'novel',
          title: title,
          createdAt: _now,
          updatedAt: _now,
        ),
      );
  await database
      .into(database.libraryEntries)
      .insert(
        LibraryEntriesCompanion.insert(
          id: 'entry-$id',
          mediaItemId: id,
          favorite: false,
          addedAt: addedAt ?? _now,
          lastOpenedAt: Value(lastOpenedAt),
          archivedAt: Value(archivedAt),
        ),
      );
}
