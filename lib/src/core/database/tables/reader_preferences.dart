import 'package:drift/drift.dart';

import '../converters/date_time_millis_converter.dart';
import 'media_items.dart';

@TableIndex.sql(
  "CREATE UNIQUE INDEX reader_preferences_global_idx "
  "ON reader_preferences(scope) WHERE scope = 'global'",
)
@TableIndex.sql(
  "CREATE UNIQUE INDEX reader_preferences_media_idx "
  "ON reader_preferences(media_item_id) WHERE scope = 'mediaItem'",
)
class ReaderPreferences extends Table {
  TextColumn get id => text()();

  TextColumn get scope => text()();

  TextColumn get mediaItemId => text().nullable().references(
    MediaItems,
    #id,
    onDelete: KeyAction.cascade,
  )();

  RealColumn get fontSize => real().nullable()();

  RealColumn get lineHeight => real().nullable()();

  TextColumn get themeKey => text().nullable()();

  TextColumn get readingMode => text().nullable()();

  IntColumn get updatedAt => integer().map(const DateTimeMillisConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (scope IN ('global', 'mediaItem'))",
    "CHECK ((scope = 'global' AND media_item_id IS NULL) OR "
        "(scope = 'mediaItem' AND media_item_id IS NOT NULL))",
  ];
}
