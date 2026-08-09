final class Bookmark {
  const Bookmark({
    required this.id,
    required this.mediaItemId,
    required this.contentUnitId,
    required this.locator,
    required this.label,
    required this.createdAt,
    this.deletedAt,
  });

  final String id;
  final String mediaItemId;
  final String contentUnitId;
  final String locator;
  final String label;
  final DateTime createdAt;
  final DateTime? deletedAt;
}
