import 'package:drift/drift.dart';

import '../converters/date_time_millis_converter.dart';
import 'media_items.dart';

@TableIndex(name: 'import_records_fingerprint_idx', columns: {#fingerprint})
class ImportRecords extends Table {
  TextColumn get id => text()();

  TextColumn get mediaItemId => text()
      .references(MediaItems, #id, onDelete: KeyAction.cascade)
      .nullable()();

  TextColumn get sourcePath => text()();

  TextColumn get sourceKind => text()();

  IntColumn get fileSize => integer()();

  IntColumn get modifiedAt =>
      integer().map(const DateTimeMillisConverter()).nullable()();

  TextColumn get fingerprint => text()();

  TextColumn get textEncoding => text().nullable()();

  TextColumn get status => text()();

  TextColumn get errorCode => text().nullable()();

  IntColumn get createdAt => integer().map(const DateTimeMillisConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (source_kind IN "
        "('txtFile', 'epubFile', 'mangaDirectory', 'mangaArchive'))",
    "CHECK (status IN ('pending', 'completed', 'failed', 'missing'))",
    "CHECK (text_encoding IS NULL OR text_encoding IN "
        "('utf8', 'utf16le', 'utf16be', 'gb18030'))",
    'CHECK (file_size >= 0)',
  ];
}
