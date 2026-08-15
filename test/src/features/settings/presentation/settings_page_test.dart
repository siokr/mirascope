import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/settings/domain/effective_reader_preference.dart';
import 'package:mirascope/src/features/settings/domain/reader_preference.dart';
import 'package:mirascope/src/features/settings/domain/reader_preference_repository.dart';
import 'package:mirascope/src/features/settings/presentation/settings_page.dart';
import 'package:mirascope/src/features/manga/application/manga_providers.dart';
import 'package:mirascope/src/features/manga/domain/manga_page_cache.dart';

void main() {
  testWidgets('settings remain usable on a narrow screen with large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readerPreferenceRepositoryProvider.overrideWithValue(_Repository()),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('跟随系统'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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

  testWidgets(
    'clears only the regenerable manga page cache after confirmation',
    (tester) async {
      final cache = _PageCache();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readerPreferenceRepositoryProvider.overrideWithValue(_Repository()),
            mangaPageCacheProvider.overrideWith((ref) async => cache),
          ],
          child: const MaterialApp(home: SettingsPage()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).last, const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('清理漫画页面缓存').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '清理'));
      await tester.pumpAndSettle();

      expect(cache.clearCount, 1);
      expect(find.text('漫画页面缓存已清理'), findsOneWidget);
    },
  );
}

final class _PageCache implements MangaPageCache {
  var clearCount = 0;
  @override
  Future<void> clear() async => clearCount++;
  @override
  Future<Uint8List?> get(MangaPageCacheKey key) async => null;
  @override
  Future<void> put(MangaPageCacheKey key, Uint8List bytes) async {}
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
