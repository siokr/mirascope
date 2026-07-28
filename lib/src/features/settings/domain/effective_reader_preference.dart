import 'reader_preference.dart';

final class EffectiveReaderPreference {
  const EffectiveReaderPreference({
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
