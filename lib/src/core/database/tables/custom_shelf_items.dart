import 'package:drift/drift.dart';

import '../converters/date_time_millis_converter.dart';
import 'custom_shelves.dart';
import 'media_items.dart';

@TableIndex(
  name: 'custom_shelf_items_shelf_order_idx',
  columns: {#shelfId, #orderIndex},
)
class CustomShelfItems extends Table {
  TextColumn get shelfId =>
      text().references(CustomShelves, #id, onDelete: KeyAction.cascade)();
  TextColumn get mediaItemId =>
      text().references(MediaItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get orderIndex => integer()();
  IntColumn get addedAt => integer().map(const DateTimeMillisConverter())();

  @override
  Set<Column> get primaryKey => {shelfId, mediaItemId};
}
