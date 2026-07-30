import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const chineseFontFamily = 'Microsoft YaHei UI';
  static const chineseFontFallback = [
    'Microsoft YaHei',
    'Noto Sans CJK SC',
    'Noto Sans SC',
    'PingFang SC',
    'sans-serif',
  ];

  static final light = _buildTheme(
    brightness: Brightness.light,
    colorSchemeSeed: const Color(0xFF5B5BD6),
  );

  static final dark = _buildTheme(
    brightness: Brightness.dark,
    colorSchemeSeed: const Color(0xFF8C8CFF),
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color colorSchemeSeed,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorSchemeSeed: colorSchemeSeed,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: chineseFontFamily,
        fontFamilyFallback: chineseFontFallback,
      ),
      primaryTextTheme: base.primaryTextTheme.apply(
        fontFamily: chineseFontFamily,
        fontFamilyFallback: chineseFontFallback,
      ),
    );
  }
}
