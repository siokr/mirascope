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

  test('archived stream contains only archived entries', () async {
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

    final items = await repository.watchArchivedLibrary().first;

    expect(items.map((item) => item.mediaItem.id).toList(), ['archived']);
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

  test('active ordering uses entry id as a stable final tie-breaker', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(
      database,
      id: 'z-last',
      entryId: 'entry-z',
      title: 'Z',
    );
    await _insertMediaAndLibraryEntry(
      database,
      id: 'a-first',
      entryId: 'entry-a',
      title: 'A',
    );

    final items = await repository.watchActiveLibrary().first;

    expect(items.map((item) => item.mediaItem.id).toList(), [
      'a-first',
      'z-last',
    ]);
  });

  test(
    'archived ordering uses archivedAt then addedAt then entry id',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final repository = DriftMediaLibraryRepository(database);
      await _insertMediaAndLibraryEntry(
        database,
        id: 'older-archive',
        title: 'Older archive',
        archivedAt: _now,
        addedAt: _now.add(const Duration(hours: 4)),
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'newer-added-z',
        entryId: 'entry-z',
        title: 'Newer added Z',
        archivedAt: _now.add(const Duration(hours: 1)),
        addedAt: _now.add(const Duration(hours: 3)),
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'newer-added-a',
        entryId: 'entry-a',
        title: 'Newer added A',
        archivedAt: _now.add(const Duration(hours: 1)),
        addedAt: _now.add(const Duration(hours: 3)),
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'same-archive-older-added',
        title: 'Same archive older added',
        archivedAt: _now.add(const Duration(hours: 1)),
        addedAt: _now.add(const Duration(hours: 2)),
      );

      final items = await repository.watchArchivedLibrary().first;

      expect(items.map((item) => item.mediaItem.id).toList(), [
        'newer-added-a',
        'newer-added-z',
        'same-archive-older-added',
        'older-archive',
      ]);
    },
  );

  test('markOpened stores UTC and moves the item to the front', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(
      database,
      id: 'already-opened',
      title: 'Already opened',
      lastOpenedAt: _now,
    );
    await _insertMediaAndLibraryEntry(
      database,
      id: 'newly-opened',
      title: 'Newly opened',
    );
    final localTime = DateTime(2026, 7, 29, 18, 30);

    await repository.markOpened('newly-opened', localTime);

    final items = await repository.watchActiveLibrary().first;
    final updated = items.first.libraryEntry.lastOpenedAt;
    expect(items.first.mediaItem.id, 'newly-opened');
    expect(updated, localTime.toUtc());
    expect(updated!.isUtc, isTrue);
  });

  test('markOpened rejects archived and missing entries', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(
      database,
      id: 'archived',
      title: 'Archived',
      archivedAt: _now,
    );

    await expectLater(
      repository.markOpened('archived', _now),
      throwsStateError,
    );
    await expectLater(repository.markOpened('missing', _now), throwsStateError);
  });

  test('archive and restore reject invalid current states', () async {
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

    await expectLater(repository.archive('archived', _now), throwsStateError);
    await expectLater(repository.archive('missing', _now), throwsStateError);
    await expectLater(repository.restore('active'), throwsStateError);
    await expectLater(repository.restore('missing'), throwsStateError);
  });

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
            mediaItemId: const Value('media-1'),
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
  String? entryId,
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
          id: entryId ?? 'entry-$id',
          mediaItemId: id,
          favorite: false,
          addedAt: addedAt ?? _now,
          lastOpenedAt: Value(lastOpenedAt),
          archivedAt: Value(archivedAt),
        ),
      );
}
