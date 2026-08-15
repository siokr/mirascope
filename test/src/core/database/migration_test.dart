import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';

import '../../../generated_migrations/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('generated v1 schema opens with all six application tables', () async {
    final schema = await verifier.schemaAt(1);
    addTearDown(schema.close);

    final tables = schema.rawDatabase
        .select(
          "SELECT name FROM sqlite_schema "
          "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' "
          'ORDER BY name',
        )
        .map((row) => row['name'] as String)
        .toList();

    expect(tables, [
      'content_units',
      'import_records',
      'library_entries',
      'media_items',
      'reader_preferences',
      'reading_progress',
    ]);
  });

  test(
    'current AppDatabase onCreate matches the generated v5 schema',
    () async {
      final database = AppDatabase.inMemory();
      addTearDown(database.close);

      await database.customSelect('SELECT 1').getSingle();

      await verifier.migrateAndValidate(
        database,
        5,
        options: const ValidationOptions(validateDropped: true),
      );
    },
  );

  test(
    'v5 enables foreign keys and contains every declared relation and index',
    () async {
      final database = AppDatabase.inMemory();
      addTearDown(database.close);

      await database.customSelect('SELECT 1').getSingle();

      final foreignKeysEnabled = await database
          .customSelect('PRAGMA foreign_keys')
          .map((row) => row.read<int>('foreign_keys'))
          .getSingle();
      expect(foreignKeysEnabled, 1);

      final foreignKeys = <String>{};
      for (final table in [
        'library_entries',
        'content_units',
        'reading_progress',
        'reader_preferences',
        'import_records',
        'bookmarks',
        'manga_pages',
        'manga_reader_preferences',
      ]) {
        final rows = await database
            .customSelect('PRAGMA foreign_key_list($table)')
            .get();
        for (final row in rows) {
          foreignKeys.add(
            '$table.${row.read<String>('from')} -> '
            '${row.read<String>('table')}.${row.read<String>('to')} '
            '${row.read<String>('on_delete')}',
          );
        }
      }
      expect(foreignKeys, {
        'library_entries.media_item_id -> media_items.id CASCADE',
        'content_units.media_item_id -> media_items.id CASCADE',
        'reading_progress.media_item_id -> media_items.id CASCADE',
        'reading_progress.content_unit_id -> content_units.id CASCADE',
        'reader_preferences.media_item_id -> media_items.id CASCADE',
        'import_records.media_item_id -> media_items.id CASCADE',
        'bookmarks.media_item_id -> media_items.id CASCADE',
        'bookmarks.content_unit_id -> content_units.id CASCADE',
        'manga_pages.content_unit_id -> content_units.id CASCADE',
        'manga_reader_preferences.media_item_id -> media_items.id CASCADE',
      });

      final namedIndexes = await database
          .customSelect(
            "SELECT name FROM sqlite_schema "
            "WHERE type = 'index' AND name NOT LIKE 'sqlite_autoindex_%' "
            'ORDER BY name',
          )
          .map((row) => row.read<String>('name'))
          .get();
      expect(namedIndexes, [
        'bookmarks_media_created_idx',
        'import_records_fingerprint_idx',
        'media_items_type_updated_idx',
        'reader_preferences_global_idx',
        'reader_preferences_media_idx',
      ]);
    },
  );

  test('v4 upgrades to v5 and preserves manga preferences', () async {
    final schema = await verifier.schemaAt(4);
    schema.rawDatabase.execute(
      'INSERT INTO media_items '
      '(id, media_type, title, created_at, updated_at) '
      "VALUES ('existing-manga', 'manga', 'Existing manga', 1, 1)",
    );
    schema.rawDatabase.execute(
      'INSERT INTO manga_reader_preferences '
      '(id, media_item_id, reading_mode, page_turn_direction, updated_at) '
      "VALUES ('preference', 'existing-manga', 'horizontal', "
      "'rightToLeft', 1)",
    );
    final database = AppDatabase(schema.newConnection());
    addTearDown(database.close);

    await verifier.migrateAndValidate(
      database,
      5,
      options: const ValidationOptions(validateDropped: true),
    );

    final preference = await database
        .select(database.mangaReaderPreferences)
        .getSingle();
    expect(preference.readingMode, 'horizontal');
    expect(preference.pageTurnDirection, 'rightToLeft');
    await database.customStatement(
      "UPDATE manga_reader_preferences SET reading_mode = 'doublePage'",
    );
  });

  test('v2 upgrades to v3 and preserves existing reading data', () async {
    final schema = await verifier.schemaAt(2);
    schema.rawDatabase.execute(
      'INSERT INTO media_items '
      '(id, media_type, title, created_at, updated_at) '
      "VALUES ('existing-media', 'novel', 'Existing', 1, 1)",
    );
    final database = AppDatabase(schema.newConnection());
    addTearDown(database.close);

    await verifier.migrateAndValidate(
      database,
      3,
      options: const ValidationOptions(validateDropped: true),
    );

    expect(await database.select(database.mediaItems).getSingle(), isNotNull);
    expect(await database.select(database.bookmarks).get(), isEmpty);
  });

  for (final legacyVersion in [1, 2]) {
    test('v$legacyVersion upgrades directly to v5', () async {
      final schema = await verifier.schemaAt(legacyVersion);
      schema.rawDatabase.execute(
        'INSERT INTO media_items '
        '(id, media_type, title, created_at, updated_at) '
        "VALUES ('legacy-media', 'novel', 'Legacy', 1, 1)",
      );
      final database = AppDatabase(schema.newConnection());
      addTearDown(database.close);

      await verifier.migrateAndValidate(
        database,
        5,
        options: const ValidationOptions(validateDropped: true),
      );

      expect(
        (await database.select(database.mediaItems).getSingle()).title,
        'Legacy',
      );
      expect(await database.select(database.mangaPages).get(), isEmpty);
    });
  }

  test('v3 upgrades to v5 and preserves existing novel data', () async {
    final schema = await verifier.schemaAt(3);
    schema.rawDatabase.execute(
      'INSERT INTO media_items '
      '(id, media_type, title, created_at, updated_at) '
      "VALUES ('existing-novel', 'novel', 'Existing novel', 1, 1)",
    );
    schema.rawDatabase.execute(
      'INSERT INTO content_units '
      '(id, media_item_id, unit_type, title, order_index, content_ref, '
      'source_locator, content_hash) '
      "VALUES ('existing-chapter', 'existing-novel', 'chapter', 'Chapter', "
      "0, 'content', 'source', 'hash')",
    );
    schema.rawDatabase.execute(
      'INSERT INTO reading_progress '
      '(id, media_item_id, content_unit_id, locator, fraction, updated_at, '
      'revision) '
      "VALUES ('existing-progress', 'existing-novel', 'existing-chapter', "
      "'paragraph:1', 0.5, 1, 2)",
    );
    schema.rawDatabase.execute(
      'INSERT INTO reader_preferences '
      '(id, scope, media_item_id, font_size, reading_mode, updated_at) '
      "VALUES ('existing-preference', 'mediaItem', 'existing-novel', 20, "
      "'vertical', 1)",
    );
    schema.rawDatabase.execute(
      'INSERT INTO bookmarks '
      '(id, media_item_id, content_unit_id, locator, label, created_at) '
      "VALUES ('existing-bookmark', 'existing-novel', 'existing-chapter', "
      "'paragraph:1', 'Saved', 1)",
    );
    final database = AppDatabase(schema.newConnection());
    addTearDown(database.close);

    await verifier.migrateAndValidate(
      database,
      5,
      options: const ValidationOptions(validateDropped: true),
    );

    expect(
      (await database.select(database.mediaItems).getSingle()).id,
      'existing-novel',
    );
    expect(
      (await database.select(database.readingProgressEntries).getSingle())
          .locator,
      'paragraph:1',
    );
    expect(
      (await database.select(database.readerPreferences).getSingle()).fontSize,
      20,
    );
    expect(
      (await database.select(database.bookmarks).getSingle()).label,
      'Saved',
    );
    expect(await database.select(database.mangaPages).get(), isEmpty);
    expect(
      await database.select(database.mangaReaderPreferences).get(),
      isEmpty,
    );
  });

  test('v1 upgrades to v2 without guessing legacy TXT encoding', () async {
    final schema = await verifier.schemaAt(1);
    final rawDatabase = schema.rawDatabase;
    rawDatabase.execute(
      'INSERT INTO media_items '
      '(id, media_type, title, created_at, updated_at) '
      "VALUES ('legacy-media', 'novel', 'Legacy', 1, 1)",
    );
    rawDatabase.execute(
      'INSERT INTO import_records '
      '(id, media_item_id, source_path, source_kind, file_size, '
      'modified_at, fingerprint, status, error_code, created_at) '
      "VALUES ('legacy-import', 'legacy-media', 'legacy.txt', 'txtFile', "
      "10, 1, 'legacy-fingerprint', 'completed', NULL, 1)",
    );

    final database = AppDatabase(schema.newConnection());
    addTearDown(database.close);

    await verifier.migrateAndValidate(
      database,
      2,
      options: const ValidationOptions(validateDropped: true),
    );

    final record = await database.select(database.importRecords).getSingle();
    expect(record.mediaItemId, 'legacy-media');
    expect(record.textEncoding, isNull);
  });

  test('v2 permits an unlinked failed record but validates encoding', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    await database.customStatement(
      'INSERT INTO import_records '
      '(id, media_item_id, source_path, source_kind, file_size, '
      'modified_at, fingerprint, text_encoding, status, error_code, created_at) '
      "VALUES ('failed-import', NULL, 'source.txt', 'txtFile', "
      "10, 1, 'failed-fingerprint', 'utf8', 'failed', 'parse_failed', 1)",
    );

    await expectLater(
      database.customStatement(
        'INSERT INTO import_records '
        '(id, media_item_id, source_path, source_kind, file_size, '
        'modified_at, fingerprint, text_encoding, status, error_code, created_at) '
        "VALUES ('bad-encoding', NULL, 'source.txt', 'txtFile', "
        "10, 1, 'bad-fingerprint', 'system-default', 'failed', "
        "'decode_failed', 1)",
      ),
      throwsA(anything),
    );
  });

  test(
    'failed transaction rolls back its insert and preserves earlier data',
    () async {
      final database = AppDatabase.inMemory();
      addTearDown(database.close);

      await database.customStatement(
        'INSERT INTO media_items '
        '(id, media_type, title, created_at, updated_at) '
        'VALUES (?, ?, ?, ?, ?)',
        ['before-transaction', 'novel', 'Before', 1, 1],
      );

      await expectLater(
        database.transaction(() async {
          await database.customStatement(
            'INSERT INTO media_items '
            '(id, media_type, title, created_at, updated_at) '
            'VALUES (?, ?, ?, ?, ?)',
            ['inside-failed-transaction', 'novel', 'Inside', 2, 2],
          );
          throw StateError('forced_migration_failure');
        }),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'forced_migration_failure',
          ),
        ),
      );

      final ids = await database
          .customSelect('SELECT id FROM media_items ORDER BY id')
          .map((row) => row.read<String>('id'))
          .get();
      expect(ids, ['before-transaction']);
    },
  );
}
