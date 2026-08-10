enum MangaImageType {
  jpeg('image/jpeg'),
  png('image/png'),
  webp('image/webp');

  const MangaImageType(this.storageValue);

  final String storageValue;

  static MangaImageType fromStorageValue(String value) {
    for (final type in MangaImageType.values) {
      if (type.storageValue == value) {
        return type;
      }
    }
    throw ArgumentError.value(value, 'value', 'Unknown manga image type');
  }
}

final class MangaPage {
  const MangaPage({
    required this.id,
    required this.contentUnitId,
    required this.orderIndex,
    required this.contentRef,
    required this.sourceLocator,
    required this.contentHash,
    required this.imageType,
    required this.byteLength,
    this.pixelWidth,
    this.pixelHeight,
  });

  final String id;
  final String contentUnitId;
  final int orderIndex;
  final String contentRef;
  final String sourceLocator;
  final String contentHash;
  final MangaImageType imageType;
  final int byteLength;
  final int? pixelWidth;
  final int? pixelHeight;
}
