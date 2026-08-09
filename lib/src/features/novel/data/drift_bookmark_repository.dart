import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/bookmark.dart' as domain;
import '../domain/bookmark_repository.dart';

final class DriftBookmarkRepository implements BookmarkRepository {
  DriftBookmarkRepository(this.database);
  final AppDatabase database;

  @override
  Future<List<domain.Bookmark>> findForMedia(String mediaItemId) async {
    final rows =
        await (database.select(database.bookmarks)
              ..where(
                (row) =>
                    row.mediaItemId.equals(mediaItemId) &
                    row.deletedAt.isNull(),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<void> save(domain.Bookmark bookmark) async {
    final ownsUnit =
        await (database.select(database.contentUnits)..where(
              (row) =>
                  row.id.equals(bookmark.contentUnitId) &
                  row.mediaItemId.equals(bookmark.mediaItemId),
            ))
            .getSingleOrNull();
    if (ownsUnit == null) {
      throw ArgumentError('书签章节不属于当前作品');
    }
    await database
        .into(database.bookmarks)
        .insert(
          BookmarksCompanion.insert(
            id: bookmark.id,
            mediaItemId: bookmark.mediaItemId,
            contentUnitId: bookmark.contentUnitId,
            locator: bookmark.locator,
            label: bookmark.label,
            createdAt: bookmark.createdAt,
            deletedAt: Value(bookmark.deletedAt),
          ),
        );
  }

  @override
  Future<void> delete(String bookmarkId, DateTime deletedAt) async {
    await (database.update(database.bookmarks)
          ..where((row) => row.id.equals(bookmarkId)))
        .write(BookmarksCompanion(deletedAt: Value(deletedAt.toUtc())));
  }

  domain.Bookmark _toDomain(Bookmark row) => domain.Bookmark(
    id: row.id,
    mediaItemId: row.mediaItemId,
    contentUnitId: row.contentUnitId,
    locator: row.locator,
    label: row.label,
    createdAt: row.createdAt,
    deletedAt: row.deletedAt,
  );
}
