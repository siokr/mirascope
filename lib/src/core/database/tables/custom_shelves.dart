import 'package:drift/drift.dart';

import '../converters/date_time_millis_converter.dart';

class CustomShelves extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text().unique()();
  IntColumn get createdAt => integer().map(const DateTimeMillisConverter())();
  IntColumn get updatedAt => integer().map(const DateTimeMillisConverter())();

  @override
  Set<Column> get primaryKey => {id};
}
