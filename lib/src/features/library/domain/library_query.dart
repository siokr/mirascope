import 'media_item.dart';

enum LibrarySort {
  recentlyOpened,
  recentlyAdded,
  titleAscending,
  titleDescending,
}

final class LibraryQuery {
  const LibraryQuery({
    this.archived = false,
    this.searchText = '',
    this.mediaTypes = const {},
    this.favoriteOnly = false,
    this.sort = LibrarySort.recentlyOpened,
  });

  final bool archived;
  final String searchText;
  final Set<MediaType> mediaTypes;
  final bool favoriteOnly;
  final LibrarySort sort;

  String get normalizedSearchText => searchText.trim().toLowerCase();
}
