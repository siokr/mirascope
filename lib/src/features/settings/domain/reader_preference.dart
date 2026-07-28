enum PreferenceScope {
  global('global'),
  mediaItem('mediaItem');

  const PreferenceScope(this.storageValue);

  final String storageValue;

  static PreferenceScope fromStorageValue(String value) {
    for (final scope in PreferenceScope.values) {
      if (scope.storageValue == value) {
        return scope;
      }
    }
    throw ArgumentError.value(value, 'value', 'Unknown preference scope');
  }
}

enum ReadingMode {
  vertical('vertical');

  const ReadingMode(this.storageValue);

  final String storageValue;

  static ReadingMode fromStorageValue(String value) {
    for (final mode in ReadingMode.values) {
      if (mode.storageValue == value) {
        return mode;
      }
    }
    throw ArgumentError.value(value, 'value', 'Unknown reading mode');
  }
}

final class ReaderPreference {
  const ReaderPreference({
    required this.id,
    required this.scope,
    this.mediaItemId,
    this.fontSize,
    this.lineHeight,
    this.themeKey,
    this.readingMode,
    required this.updatedAt,
  });

  final String id;
  final PreferenceScope scope;
  final String? mediaItemId;
  final double? fontSize;
  final double? lineHeight;
  final String? themeKey;
  final ReadingMode? readingMode;
  final DateTime updatedAt;
}
