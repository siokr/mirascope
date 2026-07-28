import 'package:drift/drift.dart';

import 'media_items.dart';

class ContentUnits extends Table {
  TextColumn get id => text()();

  TextColumn get mediaItemId =>
      text().references(MediaItems, #id, onDelete: KeyAction.cascade)();

  TextColumn get unitType => text()();

  TextColumn get title => text()();

  IntColumn get orderIndex => integer()();

  TextColumn get contentRef => text()();

  TextColumn get sourceLocator => text()();

  TextColumn get contentHash => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {mediaItemId, orderIndex},
  ];

  @override
  List<String> get customConstraints => [
    "CHECK (unit_type IN ('chapter'))",
    'CHECK (order_index >= 0)',
  ];
}
