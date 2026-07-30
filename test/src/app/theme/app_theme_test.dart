import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/app/theme/app_theme.dart';

void main() {
  test('app themes use Material 3 and matching brightness', () {
    expect(AppTheme.light.useMaterial3, isTrue);
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.useMaterial3, isTrue);
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(
      AppTheme.light.textTheme.bodyMedium?.fontFamily,
      AppTheme.chineseFontFamily,
    );
    expect(
      AppTheme.dark.textTheme.bodyMedium?.fontFamily,
      AppTheme.chineseFontFamily,
    );
    expect(
      AppTheme.light.textTheme.bodyMedium?.fontFamilyFallback,
      AppTheme.chineseFontFallback,
    );
  });
}
