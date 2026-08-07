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
import 'package:mirascope/src/features/novel/domain/progress_write_result.dart';
import 'package:mirascope/src/features/novel/domain/reading_progress.dart';
import 'package:mirascope/src/features/novel/domain/reading_progress_repository.dart';
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
          readingProgressRepositoryProvider.overrideWithValue(
            _ProgressRepository(),
          ),
        ],
        child: MaterialApp(
          home: NovelReaderPage(mediaItemId: 'media-1', onExit: () {}),
        ),
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
          readingProgressRepositoryProvider.overrideWithValue(
            _ProgressRepository(),
          ),
        ],
        child: MaterialApp(
          home: NovelReaderPage(mediaItemId: 'media-1', onExit: () {}),
        ),
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
          readingProgressRepositoryProvider.overrideWithValue(
            _ProgressRepository(),
          ),
        ],
        child: MaterialApp(
          home: NovelReaderPage(mediaItemId: 'media-1', onExit: () {}),
        ),
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

  testWidgets('restores semantic character position after layout', (
    tester,
  ) async {
    final longText = List.filled(200, 'A readable line').join('\n');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelReaderRepositoryProvider.overrideWith(
            (ref) async => _Repository(text: longText),
          ),
          readerPreferenceRepositoryProvider.overrideWithValue(
            _PreferenceRepository(),
          ),
          readingProgressRepositoryProvider.overrideWithValue(
            _ProgressRepository(
              stored: ReadingProgress(
                id: 'progress-1',
                mediaItemId: 'media-1',
                contentUnitId: 'unit-0',
                locator: 'char-v1:${longText.length ~/ 2}',
                fraction: 0.5,
                updatedAt: DateTime.utc(2026, 7, 29),
                revision: 2,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          home: NovelReaderPage(mediaItemId: 'media-1', onExit: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView).first,
    );
    expect(scrollView.controller!.offset, greaterThan(0));
  });

  testWidgets('up and down arrow keys scroll the current chapter', (
    tester,
  ) async {
    final longText = List.filled(300, '一行用于键盘滚动测试的正文').join('\n');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelReaderRepositoryProvider.overrideWith(
            (ref) async => _Repository(text: longText),
          ),
          readerPreferenceRepositoryProvider.overrideWithValue(
            _PreferenceRepository(),
          ),
          readingProgressRepositoryProvider.overrideWithValue(
            _ProgressRepository(),
          ),
        ],
        child: MaterialApp(
          home: NovelReaderPage(mediaItemId: 'media-1', onExit: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView).first,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(scrollView.controller!.offset, greaterThan(0));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(scrollView.controller!.offset, 0);
  });

  testWidgets(
    'renders EPUB semantic headings, styled text, and image fallback',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            novelReaderRepositoryProvider.overrideWith(
              (ref) async => _Repository(semantic: true),
            ),
            readerPreferenceRepositoryProvider.overrideWithValue(
              _PreferenceRepository(),
            ),
            readingProgressRepositoryProvider.overrideWithValue(
              _ProgressRepository(),
            ),
          ],
          child: MaterialApp(
            home: NovelReaderPage(mediaItemId: 'media-1', onExit: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EPUB 标题'), findsOneWidget);
      expect(find.text('带样式正文', findRichText: true), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.bySemanticsLabel('测试插图'), findsOneWidget);
      expect(find.byKey(const ValueKey('epub-block-0')), findsOneWidget);
    },
  );
}

final class _Repository implements NovelReaderRepository {
  _Repository({this.text, this.semantic = false});

  final String? text;
  final bool semantic;
  final book = _book();

  @override
  Future<ReaderBook?> loadBook(String mediaItemId) async => book;

  @override
  Future<ReaderChapter> readChapter(ContentUnit unit) async => semantic
      ? ReaderChapter(
          unit: unit,
          text: 'EPUB 标题\n\n带样式正文',
          blocks: const [
            ReaderBlock(
              kind: ReaderBlockKind.heading,
              text: 'EPUB 标题',
              headingLevel: 1,
            ),
            ReaderBlock(
              kind: ReaderBlockKind.paragraph,
              text: '带样式正文',
              styleSpans: [
                ReaderTextStyleSpan(
                  start: 0,
                  end: 3,
                  bold: true,
                  italic: false,
                ),
              ],
            ),
            ReaderBlock(
              kind: ReaderBlockKind.image,
              imagePath: 'Z:/missing-image.png',
              altText: '测试插图',
            ),
          ],
        )
      : ReaderChapter(unit: unit, text: text ?? 'Body ${unit.orderIndex + 1}');
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

final class _ProgressRepository implements ReadingProgressRepository {
  _ProgressRepository({this.stored});

  ReadingProgress? stored;

  @override
  Future<ReadingProgress?> findForMedia(String mediaItemId) async => stored;

  @override
  Future<ProgressWriteResult> save(ReadingProgress progress) async {
    final result = stored == null
        ? ProgressWriteResult.inserted
        : ProgressWriteResult.updated;
    stored = progress;
    return result;
  }
}
