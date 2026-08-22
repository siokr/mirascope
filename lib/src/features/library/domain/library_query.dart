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
    this.tagId,
    this.shelfId,
    this.organizationLabel,
  });

  final bool archived;
  final String searchText;
  final Set<MediaType> mediaTypes;
  final bool favoriteOnly;
  final LibrarySort sort;
  final String? tagId;
  final String? shelfId;
  final String? organizationLabel;

  String get normalizedSearchText => searchText.trim().toLowerCase();

  bool get hasActiveFilters =>
      mediaTypes.isNotEmpty ||
      favoriteOnly ||
      tagId != null ||
      shelfId != null ||
      sort != LibrarySort.recentlyOpened;

  LibraryQuery copyWith({
    bool? archived,
    String? searchText,
    Set<MediaType>? mediaTypes,
    bool? favoriteOnly,
    LibrarySort? sort,
    String? tagId,
    String? shelfId,
    String? organizationLabel,
  }) {
    return LibraryQuery(
      archived: archived ?? this.archived,
      searchText: searchText ?? this.searchText,
      mediaTypes: mediaTypes ?? this.mediaTypes,
      favoriteOnly: favoriteOnly ?? this.favoriteOnly,
      sort: sort ?? this.sort,
      tagId: tagId ?? this.tagId,
      shelfId: shelfId ?? this.shelfId,
      organizationLabel: organizationLabel ?? this.organizationLabel,
    );
  }
}
