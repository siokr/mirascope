import 'custom_shelf.dart';
import 'media_tag.dart';

abstract interface class LibraryOrganizationRepository {
  Stream<List<MediaTag>> watchTags();
  Stream<Set<String>> watchTagIdsForMedia(String mediaItemId);
  Future<void> createTag(MediaTag tag);
  Future<void> renameTag(String tagId, String name);
  Future<void> deleteTag(String tagId);
  Future<void> setTagAssigned({
    required String tagId,
    required String mediaItemId,
    required bool assigned,
    required DateTime changedAt,
  });

  Stream<List<CustomShelf>> watchShelves();
  Stream<Set<String>> watchShelfIdsForMedia(String mediaItemId);
  Future<void> createShelf(CustomShelf shelf);
  Future<void> renameShelf(String shelfId, String name, DateTime updatedAt);
  Future<void> deleteShelf(String shelfId);
  Future<void> setMediaInShelf({
    required String shelfId,
    required String mediaItemId,
    required bool included,
    required DateTime changedAt,
  });
}
