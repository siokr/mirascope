import 'effective_reader_preference.dart';
import 'reader_preference.dart';
import 'reader_preference_defaults.dart';

abstract final class ReaderPreferenceRules {
  static const minimumFontSize = 12.0;
  static const maximumFontSize = 36.0;
  static const minimumLineHeight = 1.2;
  static const maximumLineHeight = 2.4;
  static const supportedThemes = {'system', 'light', 'dark', 'sepia'};

  static bool isValidFontSize(double? value) =>
      value != null &&
      value.isFinite &&
      value >= minimumFontSize &&
      value <= maximumFontSize;

  static bool isValidLineHeight(double? value) =>
      value != null &&
      value.isFinite &&
      value >= minimumLineHeight &&
      value <= maximumLineHeight;

  static bool isValidTheme(String? value) =>
      value != null && supportedThemes.contains(value);

  static EffectiveReaderPreference resolve({
    required ReaderPreference? media,
    required ReaderPreference? global,
    required ReaderPreferenceDefaults defaults,
  }) {
    final fontCandidates = [
      media?.fontSize,
      global?.fontSize,
      defaults.fontSize,
    ];
    final lineCandidates = [
      media?.lineHeight,
      global?.lineHeight,
      defaults.lineHeight,
    ];
    final themeCandidates = [
      media?.themeKey,
      global?.themeKey,
      defaults.themeKey,
    ];
    return EffectiveReaderPreference(
      fontSize: fontCandidates.whereType<double>().firstWhere(isValidFontSize),
      lineHeight: lineCandidates.whereType<double>().firstWhere(
        isValidLineHeight,
      ),
      themeKey: themeCandidates.whereType<String>().firstWhere(isValidTheme),
      readingMode:
          media?.readingMode ?? global?.readingMode ?? defaults.readingMode,
    );
  }
}
