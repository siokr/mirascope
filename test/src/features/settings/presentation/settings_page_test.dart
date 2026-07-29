import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/settings/domain/effective_reader_preference.dart';
import 'package:mirascope/src/features/settings/domain/reader_preference.dart';
import 'package:mirascope/src/features/settings/domain/reader_preference_repository.dart';
import 'package:mirascope/src/features/settings/presentation/settings_page.dart';

void main() {
  testWidgets('global theme saves and survives provider reconstruction', (
    tester,
  ) async {
    final repository = _Repository();
    Future<void> pump() => tester.pumpWidget(
      ProviderScope(
        overrides: [
          readerPreferenceRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );

    await pump();
    await tester.pumpAndSettle();
    expect(find.text('默认阅读设置'), findsOneWidget);
    await tester.tap(find.text('深色'));
    await tester.pumpAndSettle();
    expect(repository.saved?.themeKey, 'dark');

    await tester.pumpWidget(const SizedBox());
    await pump();
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SegmentedButton<String>>(find.byType(SegmentedButton<String>))
          .selected,
      {'dark'},
    );
  });
}

final class _Repository implements ReaderPreferenceRepository {
  ReaderPreference? saved;

  @override
  Future<EffectiveReaderPreference> resolveGlobal() async {
    return EffectiveReaderPreference(
      fontSize: saved?.fontSize ?? 18,
      lineHeight: saved?.lineHeight ?? 1.6,
      themeKey: saved?.themeKey ?? 'system',
      readingMode: saved?.readingMode ?? ReadingMode.vertical,
    );
  }

  @override
  Future<EffectiveReaderPreference> resolveForMedia(String mediaItemId) =>
      resolveGlobal();

  @override
  Future<void> save(ReaderPreference preference) async => saved = preference;

  @override
  Future<ReaderPreference?> findForMedia(String mediaItemId) async => null;

  @override
  Future<ReaderPreference?> findGlobal() async => saved;
}
