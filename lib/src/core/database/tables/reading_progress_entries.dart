import 'package:drift/drift.dart';

import '../converters/date_time_millis_converter.dart';
import 'content_units.dart';
import 'media_items.dart';

class ReadingProgressEntries extends Table {
  TextColumn get id => text()();

  TextColumn get mediaItemId =>
      text().references(MediaItems, #id, onDelete: KeyAction.cascade)();

  TextColumn get contentUnitId =>
      text().references(ContentUnits, #id, onDelete: KeyAction.cascade)();

  TextColumn get locator => text()();

  RealColumn get fraction => real()();

  IntColumn get updatedAt => integer().map(const DateTimeMillisConverter())();

  IntColumn get revision => integer()();

  @override
  String get tableName => 'reading_progress';

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {mediaItemId},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (fraction >= 0 AND fraction <= 1)',
    'CHECK (revision >= 0)',
  ];
}
