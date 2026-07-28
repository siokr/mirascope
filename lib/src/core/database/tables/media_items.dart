import 'package:drift/drift.dart';

import '../converters/date_time_millis_converter.dart';

@TableIndex(
  name: 'media_items_type_updated_idx',
  columns: {#mediaType, #updatedAt},
)
class MediaItems extends Table {
  TextColumn get id => text()();

  TextColumn get mediaType => text()();

  TextColumn get title => text()();

  TextColumn get subtitle => text().nullable()();

  TextColumn get creator => text().nullable()();

  TextColumn get description => text().nullable()();

  TextColumn get coverRef => text().nullable()();

  IntColumn get createdAt => integer().map(const DateTimeMillisConverter())();

  IntColumn get updatedAt => integer().map(const DateTimeMillisConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (media_type IN ('novel', 'manga'))",
  ];
}
