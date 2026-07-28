import 'reader_preference.dart';

final class ReaderPreferenceDefaults {
  const ReaderPreferenceDefaults({
    required this.fontSize,
    required this.lineHeight,
    required this.themeKey,
    required this.readingMode,
  });

  final double fontSize;
  final double lineHeight;
  final String themeKey;
  final ReadingMode readingMode;
}
