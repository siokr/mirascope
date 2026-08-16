import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'converters/date_time_millis_converter.dart';
import 'tables/bookmarks.dart';
import 'tables/content_units.dart';
import 'tables/custom_shelf_items.dart';
import 'tables/custom_shelves.dart';
import 'tables/import_records.dart';
import 'tables/library_entries.dart';
import 'tables/manga_pages.dart';
import 'tables/manga_reader_preferences.dart';
import 'tables/media_items.dart';
import 'tables/media_tag_assignments.dart';
import 'tables/reader_preferences.dart';
import 'tables/reading_progress_entries.dart';
import 'tables/tags.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Bookmarks,
    MediaItems,
    LibraryEntries,
    ContentUnits,
    MangaPages,
    ReadingProgressEntries,
    ReaderPreferences,
    MangaReaderPreferences,
    ImportRecords,
    Tags,
    MediaTagAssignments,
    CustomShelves,
    CustomShelfItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2 && to >= 2) {
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
      if (from < 3 && to >= 3) {
        await migrator.createTable(bookmarks);
        await migrator.createIndex(bookmarksMediaCreatedIdx);
      }
      if (from < 4 && to >= 4) {
        await migrator.createTable(mangaPages);
        await migrator.createTable(mangaReaderPreferences);
      }
      if (from < 5 && to >= 5) {
        await migrator.alterTable(TableMigration(mangaReaderPreferences));
      }
      if (from < 6 && to >= 6) {
        await migrator.createTable(tags);
        await migrator.createTable(mediaTagAssignments);
        await migrator.createTable(customShelves);
        await migrator.createTable(customShelfItems);
        await migrator.createIndex(mediaTagAssignmentsMediaIdx);
        await migrator.createIndex(customShelfItemsShelfOrderIdx);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
