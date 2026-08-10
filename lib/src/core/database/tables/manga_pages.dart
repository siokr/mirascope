import 'package:drift/drift.dart';

import 'content_units.dart';

class MangaPages extends Table {
  TextColumn get id => text()();

  TextColumn get contentUnitId =>
      text().references(ContentUnits, #id, onDelete: KeyAction.cascade)();

  IntColumn get orderIndex => integer()();

  TextColumn get contentRef => text()();

  TextColumn get sourceLocator => text()();

  TextColumn get contentHash => text()();

  TextColumn get mimeType => text()();

  IntColumn get byteLength => integer()();

  IntColumn get pixelWidth => integer().nullable()();

  IntColumn get pixelHeight => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {contentUnitId, orderIndex},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (order_index >= 0)',
    "CHECK (mime_type IN ('image/jpeg', 'image/png', 'image/webp'))",
    'CHECK (byte_length >= 0)',
    'CHECK (pixel_width IS NULL OR pixel_width > 0)',
    'CHECK (pixel_height IS NULL OR pixel_height > 0)',
  ];
}
