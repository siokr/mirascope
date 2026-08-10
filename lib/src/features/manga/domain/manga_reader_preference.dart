enum MangaReadingMode {
  vertical('vertical'),
  horizontal('horizontal');

  const MangaReadingMode(this.storageValue);

  final String storageValue;

  static MangaReadingMode fromStorageValue(String value) {
    for (final mode in MangaReadingMode.values) {
      if (mode.storageValue == value) {
        return mode;
      }
    }
    throw ArgumentError.value(value, 'value', 'Unknown manga reading mode');
  }
}

enum PageTurnDirection {
  leftToRight('leftToRight'),
  rightToLeft('rightToLeft');

  const PageTurnDirection(this.storageValue);

  final String storageValue;

  static PageTurnDirection fromStorageValue(String value) {
    for (final direction in PageTurnDirection.values) {
      if (direction.storageValue == value) {
        return direction;
      }
    }
    throw ArgumentError.value(value, 'value', 'Unknown page turn direction');
  }
}

final class MangaReaderPreference {
  const MangaReaderPreference({
    required this.id,
    required this.mediaItemId,
    required this.readingMode,
    required this.pageTurnDirection,
    required this.updatedAt,
  });

  final String id;
  final String mediaItemId;
  final MangaReadingMode readingMode;
  final PageTurnDirection pageTurnDirection;
  final DateTime updatedAt;
}
