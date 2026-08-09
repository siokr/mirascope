import 'bookmark.dart';

abstract interface class BookmarkRepository {
  Future<List<Bookmark>> findForMedia(String mediaItemId);
  Future<void> save(Bookmark bookmark);
  Future<void> delete(String bookmarkId, DateTime deletedAt);
}
