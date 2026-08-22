import 'library_item.dart';
import 'library_query.dart';
import 'media_item.dart';

abstract interface class MediaLibraryRepository {
  Stream<List<LibraryItem>> watchLibrary(LibraryQuery query);
  Stream<List<LibraryItem>> watchActiveLibrary();
  Stream<List<LibraryItem>> watchArchivedLibrary();
  Future<MediaItem?> findMediaItem(String mediaItemId);
  Future<void> markOpened(String mediaItemId, DateTime openedAt);
  Future<void> setFavorite(String mediaItemId, bool favorite);
  Future<void> updateMetadata({
    required String mediaItemId,
    required String title,
    String? subtitle,
    String? creator,
    String? description,
    required DateTime updatedAt,
  });
  Future<void> updateCoverRef({
    required String mediaItemId,
    required String coverRef,
    required DateTime updatedAt,
  });
  Future<void> archive(String mediaItemId, DateTime archivedAt);
  Future<void> restore(String mediaItemId);
  Future<Set<String>> deleteApplicationData(String mediaItemId);
}
