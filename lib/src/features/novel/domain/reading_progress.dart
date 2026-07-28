final class ReadingProgress {
  const ReadingProgress({
    required this.id,
    required this.mediaItemId,
    required this.contentUnitId,
    required this.locator,
    required this.fraction,
    required this.updatedAt,
    required this.revision,
  });

  final String id;
  final String mediaItemId;
  final String contentUnitId;
  final String locator;
  final double fraction;
  final DateTime updatedAt;
  final int revision;
}
