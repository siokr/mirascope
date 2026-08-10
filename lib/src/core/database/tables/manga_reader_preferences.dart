import 'package:drift/drift.dart';

import '../converters/date_time_millis_converter.dart';
import 'media_items.dart';

class MangaReaderPreferences extends Table {
  TextColumn get id => text()();

  TextColumn get mediaItemId => text()
      .references(MediaItems, #id, onDelete: KeyAction.cascade)
      .unique()();

  TextColumn get readingMode => text()();

  TextColumn get pageTurnDirection => text()();

  IntColumn get updatedAt => integer().map(const DateTimeMillisConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (reading_mode IN ('vertical', 'horizontal'))",
    "CHECK (page_turn_direction IN ('leftToRight', 'rightToLeft'))",
  ];
}
