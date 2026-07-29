import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'converters/date_time_millis_converter.dart';
import 'tables/content_units.dart';
import 'tables/import_records.dart';
import 'tables/library_entries.dart';
import 'tables/media_items.dart';
import 'tables/reader_preferences.dart';
import 'tables/reading_progress_entries.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    MediaItems,
    LibraryEntries,
    ContentUnits,
    ReadingProgressEntries,
    ReaderPreferences,
    ImportRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.alterTable(
          TableMigration(
            importRecords,
            columnTransformer: {
              importRecords.textEncoding: const CustomExpression<String>(
                'NULL',
              ),
            },
          ),
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
