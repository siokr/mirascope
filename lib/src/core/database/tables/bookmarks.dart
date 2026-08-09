import 'package:drift/drift.dart';

import '../converters/date_time_millis_converter.dart';
import 'content_units.dart';
import 'media_items.dart';

@TableIndex(
  name: 'bookmarks_media_created_idx',
  columns: {#mediaItemId, #createdAt},
)
class Bookmarks extends Table {
  TextColumn get id => text()();
  TextColumn get mediaItemId =>
      text().references(MediaItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get contentUnitId =>
      text().references(ContentUnits, #id, onDelete: KeyAction.cascade)();
  TextColumn get locator => text()();
  TextColumn get label => text()();
  IntColumn get createdAt => integer().map(const DateTimeMillisConverter())();
  IntColumn get deletedAt =>
      integer().map(const DateTimeMillisConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
