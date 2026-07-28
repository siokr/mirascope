enum ContentUnitType {
  chapter('chapter');

  const ContentUnitType(this.storageValue);

  final String storageValue;

  static ContentUnitType fromStorageValue(String value) {
    for (final unitType in ContentUnitType.values) {
      if (unitType.storageValue == value) {
        return unitType;
      }
    }
    throw ArgumentError.value(value, 'value', 'Unknown content unit type');
  }
}

final class ContentUnit {
  const ContentUnit({
    required this.id,
    required this.mediaItemId,
    required this.unitType,
    required this.title,
    required this.orderIndex,
    required this.contentRef,
    required this.sourceLocator,
    required this.contentHash,
  });

  final String id;
  final String mediaItemId;
  final ContentUnitType unitType;
  final String title;
  final int orderIndex;
  final String contentRef;
  final String sourceLocator;
  final String contentHash;
}
