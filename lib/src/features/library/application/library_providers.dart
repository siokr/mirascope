import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../domain/library_item.dart';
import '../domain/library_query.dart';
import '../domain/custom_shelf.dart';
import '../domain/media_tag.dart';

typedef LibraryClock = DateTime Function();

final libraryClockProvider = Provider<LibraryClock>((ref) {
  return () => DateTime.now().toUtc();
});

final libraryQueryProvider =
    NotifierProvider<LibraryQueryController, LibraryQuery>(
      LibraryQueryController.new,
    );

final class LibraryQueryController extends Notifier<LibraryQuery> {
  @override
  LibraryQuery build() => const LibraryQuery();

  void setSearchText(String value) {
    state = state.copyWith(searchText: value);
  }

  void clearSearch() {
    if (state.searchText.isNotEmpty) {
      state = state.copyWith(searchText: '');
    }
  }

  void applyFilters(LibraryQuery query) {
    state = query.copyWith(archived: false, searchText: state.searchText);
  }

  void resetFilters() {
    state = LibraryQuery(searchText: state.searchText);
  }
}

final activeLibraryProvider = StreamProvider<List<LibraryItem>>((ref) {
  final query = ref.watch(libraryQueryProvider);
  return ref.watch(mediaLibraryRepositoryProvider).watchLibrary(query);
});

final archivedLibraryProvider = StreamProvider<List<LibraryItem>>((ref) {
  return ref.watch(mediaLibraryRepositoryProvider).watchArchivedLibrary();
});

final organizationTagsProvider = StreamProvider<List<MediaTag>>((ref) {
  return ref.watch(libraryOrganizationRepositoryProvider).watchTags();
});

final organizationShelvesProvider = StreamProvider<List<CustomShelf>>((ref) {
  return ref.watch(libraryOrganizationRepositoryProvider).watchShelves();
});

final mediaTagIdsProvider = StreamProvider.family<Set<String>, String>((
  ref,
  id,
) {
  return ref
      .watch(libraryOrganizationRepositoryProvider)
      .watchTagIdsForMedia(id);
});

final mediaShelfIdsProvider = StreamProvider.family<Set<String>, String>((
  ref,
  id,
) {
  return ref
      .watch(libraryOrganizationRepositoryProvider)
      .watchShelfIdsForMedia(id);
});
