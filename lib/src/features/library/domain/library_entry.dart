final class LibraryEntry {
  const LibraryEntry({
    required this.id,
    required this.mediaItemId,
    required this.favorite,
    required this.addedAt,
    this.lastOpenedAt,
    this.archivedAt,
  });

  final String id;
  final String mediaItemId;
  final bool favorite;
  final DateTime addedAt;
  final DateTime? lastOpenedAt;
  final DateTime? archivedAt;
}
