import 'package:drift/drift.dart';

import '../converters/date_time_millis_converter.dart';
import 'media_items.dart';

class LibraryEntries extends Table {
  TextColumn get id => text()();

  TextColumn get mediaItemId =>
      text().references(MediaItems, #id, onDelete: KeyAction.cascade)();

  BoolColumn get favorite => boolean()();

  IntColumn get addedAt => integer().map(const DateTimeMillisConverter())();

  IntColumn get lastOpenedAt =>
      integer().map(const DateTimeMillisConverter()).nullable()();

  IntColumn get archivedAt =>
      integer().map(const DateTimeMillisConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {mediaItemId},
  ];
}
