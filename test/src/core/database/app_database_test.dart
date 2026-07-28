import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';

import 'database_test_support.dart';

final _now = DateTime.utc(2026, 7, 28);
final _constraintViolation = throwsA(isA<Exception>());

void main() {
  test('schema version is 1 and creates exactly the six v1 tables', () async {
    final database = createTestDatabase();
    addTearDown(database.close);

    final tableRows = await database
        .customSelect(
          "SELECT name FROM sqlite_master "
          "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' "
          'ORDER BY name',
        )
        .get();

    expect(database.schemaVersion, 1);
    expect(tableRows.map((row) => row.read<String>('name')).toList(), [
      'content_units',
      'import_records',
      'library_entries',
      'media_items',
      'reader_preferences',
      'reading_progress',
    ]);
  });

  test('declares all required named indexes', () async {
    final database = createTestDatabase();
    addTearDown(database.close);

    final indexRows = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name IN (?, ?, ?, ?) ORDER BY name",
          variables: [
            const Variable('media_items_type_updated_idx'),
            const Variable('reader_preferences_global_idx'),
            const Variable('reader_preferences_media_idx'),
            const Variable('import_records_fingerprint_idx'),
          ],
        )
        .get();

    expect(indexRows.map((row) => row.read<String>('name')).toList(), [
      'import_records_fingerprint_idx',
      'media_items_type_updated_idx',
      'reader_preferences_global_idx',
      'reader_preferences_media_idx',
    ]);
  });

  test('enables SQLite foreign key enforcement', () async {
    final database = createTestDatabase();
    addTearDown(database.close);

    final row = await database.customSelect('PRAGMA foreign_keys').getSingle();

    expect(row.read<int>('foreign_keys'), 1);
  });

  test('foreign keys reject orphaned dependent rows', () async {
    final database = createTestDatabase();
    addTearDown(database.close);

    await expectLater(
      _insertLibraryEntry(database, id: 'library-1', mediaItemId: 'missing'),
      _constraintViolation,
    );
  });

  test('deleting a media item cascades to all dependent tables', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _insertMediaItem(database);
    await _insertLibraryEntry(database);
    await _insertContentUnit(database);
    await _insertReadingProgress(database);
    await _insertReaderPreference(
      database,
      id: 'preference-1',
      scope: 'mediaItem',
      mediaItemId: 'media-1',
    );
    await _insertImportRecord(database);

    await (database.delete(
      database.mediaItems,
    )..where((row) => row.id.equals('media-1'))).go();

    expect(await database.select(database.libraryEntries).get(), isEmpty);
    expect(await database.select(database.contentUnits).get(), isEmpty);
    expect(
      await database.select(database.readingProgressEntries).get(),
      isEmpty,
    );
    expect(await database.select(database.readerPreferences).get(), isEmpty);
    expect(await database.select(database.importRecords).get(), isEmpty);
  });

  test('timestamps are stored as UTC epoch milliseconds', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final localTime = DateTime.parse('2026-07-28T08:00:00+08:00');

    await _insertMediaItem(database, createdAt: localTime);

    final rawRow = await database
        .customSelect(
          'SELECT created_at FROM media_items WHERE id = ?',
          variables: const [Variable('media-1')],
        )
        .getSingle();
    final generatedRow = await database.select(database.mediaItems).getSingle();
    expect(rawRow.read<int>('created_at'), 1785196800000);
    expect(generatedRow.createdAt, DateTime.utc(2026, 7, 28));
    expect(generatedRow.createdAt.isUtc, isTrue);
  });

  test('duplicate library entry media item IDs are rejected', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _insertMediaItem(database);
    await _insertLibraryEntry(database, id: 'library-1');

    await expectLater(
      _insertLibraryEntry(database, id: 'library-2'),
      _constraintViolation,
    );
  });

  test(
    'duplicate content unit order within one media item is rejected',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      await _insertMediaItem(database);
      await _insertContentUnit(database, id: 'unit-1', orderIndex: 0);

      await expectLater(
        _insertContentUnit(database, id: 'unit-2', orderIndex: 0),
        _constraintViolation,
      );
    },
  );

  test('negative content unit order is rejected', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _insertMediaItem(database);

    await expectLater(
      _insertContentUnit(database, orderIndex: -1),
      _constraintViolation,
    );
  });

  for (final fraction in [-0.01, 1.01]) {
    test(
      'reading fraction $fraction outside the closed interval is rejected',
      () async {
        final database = createTestDatabase();
        addTearDown(database.close);
        await _insertMediaItem(database);
        await _insertContentUnit(database);

        await expectLater(
          _insertReadingProgress(database, fraction: fraction),
          _constraintViolation,
        );
      },
    );
  }

  test('negative reading revision is rejected', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _insertMediaItem(database);
    await _insertContentUnit(database);

    await expectLater(
      _insertReadingProgress(database, revision: -1),
      _constraintViolation,
    );
  });

  test('global preference with a media ID is rejected', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _insertMediaItem(database);

    await expectLater(
      _insertReaderPreference(
        database,
        id: 'preference-1',
        scope: 'global',
        mediaItemId: 'media-1',
      ),
      _constraintViolation,
    );
  });

  test('media item preference without a media ID is rejected', () async {
    final database = createTestDatabase();
    addTearDown(database.close);

    await expectLater(
      _insertReaderPreference(database, id: 'preference-1', scope: 'mediaItem'),
      _constraintViolation,
    );
  });

  test('two global preferences are rejected', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _insertReaderPreference(
      database,
      id: 'preference-1',
      scope: 'global',
    );

    await expectLater(
      _insertReaderPreference(database, id: 'preference-2', scope: 'global'),
      _constraintViolation,
    );
  });

  test('two preferences for one media item are rejected', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _insertMediaItem(database);
    await _insertReaderPreference(
      database,
      id: 'preference-1',
      scope: 'mediaItem',
      mediaItemId: 'media-1',
    );

    await expectLater(
      _insertReaderPreference(
        database,
        id: 'preference-2',
        scope: 'mediaItem',
        mediaItemId: 'media-1',
      ),
      _constraintViolation,
    );
  });

  test('negative import file size is rejected', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _insertMediaItem(database);

    await expectLater(
      _insertImportRecord(database, fileSize: -1),
      _constraintViolation,
    );
  });

  test('unsupported enum storage strings are rejected', () async {
    final database = createTestDatabase();
    addTearDown(database.close);

    await expectLater(
      _insertMediaItem(database, id: 'invalid-media', mediaType: 'audio'),
      _constraintViolation,
    );

    await _insertMediaItem(database);
    await expectLater(
      _insertContentUnit(database, id: 'invalid-unit', unitType: 'page'),
      _constraintViolation,
    );
    await expectLater(
      _insertReaderPreference(
        database,
        id: 'invalid-preference',
        scope: 'unknown',
      ),
      _constraintViolation,
    );
    await expectLater(
      _insertImportRecord(
        database,
        id: 'invalid-source-kind',
        sourceKind: 'url',
      ),
      _constraintViolation,
    );
    await expectLater(
      _insertImportRecord(database, id: 'invalid-status', status: 'unknown'),
      _constraintViolation,
    );
  });

  test('unsupported reading mode storage string is rejected', () async {
    final database = createTestDatabase();
    addTearDown(database.close);

    await expectLater(
      _insertReaderPreference(
        database,
        id: 'invalid-reading-mode',
        scope: 'global',
        readingMode: 'horizontal',
      ),
      _constraintViolation,
    );
  });
}

Future<void> _insertMediaItem(
  AppDatabase database, {
  String id = 'media-1',
  String mediaType = 'novel',
  DateTime? createdAt,
}) {
  return database
      .into(database.mediaItems)
      .insert(
        MediaItemsCompanion.insert(
          id: id,
          mediaType: mediaType,
          title: 'Example title',
          createdAt: createdAt ?? _now,
          updatedAt: _now,
        ),
      );
}

Future<void> _insertLibraryEntry(
  AppDatabase database, {
  String id = 'library-1',
  String mediaItemId = 'media-1',
}) {
  return database
      .into(database.libraryEntries)
      .insert(
        LibraryEntriesCompanion.insert(
          id: id,
          mediaItemId: mediaItemId,
          favorite: false,
          addedAt: _now,
        ),
      );
}

Future<void> _insertContentUnit(
  AppDatabase database, {
  String id = 'unit-1',
  String mediaItemId = 'media-1',
  String unitType = 'chapter',
  int orderIndex = 0,
}) {
  return database
      .into(database.contentUnits)
      .insert(
        ContentUnitsCompanion.insert(
          id: id,
          mediaItemId: mediaItemId,
          unitType: unitType,
          title: 'Chapter 1',
          orderIndex: orderIndex,
          contentRef: 'content/unit-1',
          sourceLocator: 'source#chapter-1',
          contentHash: 'hash-1',
        ),
      );
}

Future<void> _insertReadingProgress(
  AppDatabase database, {
  double fraction = 0.5,
  int revision = 0,
}) {
  return database
      .into(database.readingProgressEntries)
      .insert(
        ReadingProgressEntriesCompanion.insert(
          id: 'progress-1',
          mediaItemId: 'media-1',
          contentUnitId: 'unit-1',
          locator: 'paragraph:1',
          fraction: fraction,
          updatedAt: _now,
          revision: revision,
        ),
      );
}

Future<void> _insertReaderPreference(
  AppDatabase database, {
  required String id,
  required String scope,
  String? mediaItemId,
  String? readingMode,
}) {
  return database
      .into(database.readerPreferences)
      .insert(
        ReaderPreferencesCompanion.insert(
          id: id,
          scope: scope,
          mediaItemId: Value(mediaItemId),
          readingMode: Value(readingMode),
          updatedAt: _now,
        ),
      );
}

Future<void> _insertImportRecord(
  AppDatabase database, {
  String id = 'import-1',
  String sourceKind = 'txtFile',
  int fileSize = 100,
  String status = 'completed',
}) {
  return database
      .into(database.importRecords)
      .insert(
        ImportRecordsCompanion.insert(
          id: id,
          mediaItemId: 'media-1',
          sourcePath: 'C:/books/example.txt',
          sourceKind: sourceKind,
          fileSize: fileSize,
          fingerprint: 'fingerprint-$id',
          status: status,
          createdAt: _now,
        ),
      );
}
