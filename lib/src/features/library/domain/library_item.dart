import 'library_entry.dart';
import 'media_item.dart';

final class LibraryItem {
  const LibraryItem({required this.mediaItem, required this.libraryEntry});

  final MediaItem mediaItem;
  final LibraryEntry libraryEntry;
}
