import '../../library/domain/media_item.dart';

final class ReadingHistoryItem {
  const ReadingHistoryItem({
    required this.mediaItemId,
    required this.title,
    required this.mediaType,
    required this.lastOpenedAt,
    this.coverRef,
    this.progressUpdatedAt,
    this.fraction,
  });

  final String mediaItemId;
  final String title;
  final MediaType mediaType;
  final String? coverRef;
  final DateTime lastOpenedAt;
  final DateTime? progressUpdatedAt;
  final double? fraction;
}
