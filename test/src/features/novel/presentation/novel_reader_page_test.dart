import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/novel/application/novel_providers.dart';
import 'package:mirascope/src/features/novel/domain/content_unit.dart';
import 'package:mirascope/src/features/novel/domain/novel_reader_repository.dart';
import 'package:mirascope/src/features/novel/domain/reader_book.dart';
import 'package:mirascope/src/features/novel/presentation/novel_reader_page.dart';
import 'package:mirascope/src/features/settings/domain/effective_reader_preference.dart';
import 'package:mirascope/src/features/settings/domain/reader_preference.dart';
import 'package:mirascope/src/features/settings/domain/reader_preference_repository.dart';

void main() {
  testWidgets('shows vertical content and respects first and last boundaries', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelReaderRepositoryProvider.overrideWith(
            (ref) async => _Repository(),
          ),
          readerPreferenceRepositoryProvider.overrideWithValue(
            _PreferenceRepository(),
          ),
        ],
        child: const MaterialApp(home: NovelReaderPage(mediaItemId: 'media-1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Body 1'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, '上一章'))
          .onPressed,
      isNull,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Body 2'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, '下一章'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('directory selects a chapter', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelReaderRepositoryProvider.overrideWith(
            (ref) async => _Repository(),
          ),
          readerPreferenceRepositoryProvider.overrideWithValue(
            _PreferenceRepository(),
          ),
        ],
        child: const MaterialApp(home: NovelReaderPage(mediaItemId: 'media-1')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('目录'), findsOneWidget);
    await tester.tap(find.text('Chapter 2'));
    await tester.pumpAndSettle();
    expect(find.text('Body 2'), findsOneWidget);
  });

  testWidgets('settings preview font and sepia theme immediately', (
    tester,
  ) async {
    final preferences = _PreferenceRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelReaderRepositoryProvider.overrideWith(
            (ref) async => _Repository(),
          ),
          readerPreferenceRepositoryProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(home: NovelReaderPage(mediaItemId: 'media-1')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('reader-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('护眼'));
    await tester.pump();

    expect(
      tester.widget<ColoredBox>(find.byKey(const Key('reader-surface'))).color,
      const Color(0xfff3ead3),
    );
    expect(preferences.saved.last.themeKey, 'sepia');
  });
}

final class _Repository implements NovelReaderRepository {
  final book = _book();

  @override
  Future<ReaderBook?> loadBook(String mediaItemId) async => book;

  @override
  Future<ReaderChapter> readChapter(ContentUnit unit) async =>
      ReaderChapter(unit: unit, text: 'Body ${unit.orderIndex + 1}');
}

ReaderBook _book() {
  final now = DateTime.utc(2026, 7, 29);
  return ReaderBook(
    mediaItem: MediaItem(
      id: 'media-1',
      mediaType: MediaType.novel,
      title: 'Book',
      createdAt: now,
      updatedAt: now,
    ),
    chapters: [_chapter(0), _chapter(1)],
  );
}

ContentUnit _chapter(int index) => ContentUnit(
  id: 'unit-$index',
  mediaItemId: 'media-1',
  unitType: ContentUnitType.chapter,
  title: 'Chapter ${index + 1}',
  orderIndex: index,
  contentRef: 'content/media-1.txt',
  sourceLocator: 'txt-v1:0:0:1',
  contentHash: 'hash-$index',
);

final class _PreferenceRepository implements ReaderPreferenceRepository {
  final saved = <ReaderPreference>[];

  @override
  Future<EffectiveReaderPreference> resolveForMedia(String mediaItemId) async {
    if (saved.isNotEmpty) {
      final latest = saved.last;
      return EffectiveReaderPreference(
        fontSize: latest.fontSize ?? 18,
        lineHeight: latest.lineHeight ?? 1.6,
        themeKey: latest.themeKey ?? 'system',
        readingMode: latest.readingMode ?? ReadingMode.vertical,
      );
    }
    return const EffectiveReaderPreference(
      fontSize: 18,
      lineHeight: 1.6,
      themeKey: 'system',
      readingMode: ReadingMode.vertical,
    );
  }

  @override
  Future<EffectiveReaderPreference> resolveGlobal() =>
      resolveForMedia('global');

  @override
  Future<void> save(ReaderPreference preference) async => saved.add(preference);

  @override
  Future<ReaderPreference?> findForMedia(String mediaItemId) async => null;

  @override
  Future<ReaderPreference?> findGlobal() async => null;
}
