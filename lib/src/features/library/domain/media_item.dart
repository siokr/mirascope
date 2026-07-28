enum MediaType {
  novel('novel'),
  manga('manga');

  const MediaType(this.storageValue);

  final String storageValue;

  static MediaType fromStorageValue(String value) {
    for (final mediaType in MediaType.values) {
      if (mediaType.storageValue == value) {
        return mediaType;
      }
    }
    throw ArgumentError.value(value, 'value', 'Unknown media type');
  }
}

final class MediaItem {
  const MediaItem({
    required this.id,
    required this.mediaType,
    required this.title,
    this.subtitle,
    this.creator,
    this.description,
    this.coverRef,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final MediaType mediaType;
  final String title;
  final String? subtitle;
  final String? creator;
  final String? description;
  final String? coverRef;
  final DateTime createdAt;
  final DateTime updatedAt;
}
