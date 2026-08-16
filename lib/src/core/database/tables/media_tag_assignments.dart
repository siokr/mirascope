import 'package:drift/drift.dart';

import '../converters/date_time_millis_converter.dart';
import 'media_items.dart';
import 'tags.dart';

@TableIndex(
  name: 'media_tag_assignments_media_idx',
  columns: {#mediaItemId, #createdAt},
)
class MediaTagAssignments extends Table {
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();
  TextColumn get mediaItemId =>
      text().references(MediaItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get createdAt => integer().map(const DateTimeMillisConverter())();

  @override
  Set<Column> get primaryKey => {tagId, mediaItemId};
}
