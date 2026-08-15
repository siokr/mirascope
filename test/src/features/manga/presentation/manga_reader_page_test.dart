import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/manga/application/manga_providers.dart';
import 'package:mirascope/src/features/manga/domain/manga_page.dart';
import 'package:mirascope/src/features/manga/domain/manga_reader_book.dart';
import 'package:mirascope/src/features/manga/domain/manga_reader_preference.dart';
import 'package:mirascope/src/features/manga/domain/manga_reader_preference_repository.dart';
import 'package:mirascope/src/features/manga/presentation/manga_reader_page.dart';
import 'package:mirascope/src/features/novel/domain/content_unit.dart';
import 'package:mirascope/src/features/novel/domain/progress_write_result.dart';
import 'package:mirascope/src/features/novel/domain/reading_progress.dart';
import 'package:mirascope/src/features/novel/domain/reading_progress_repository.dart';

import '../../../../support/manga_test_fixture.dart';

void main() {
  testWidgets('opens requested chapter in vertical mode and exits', (
    tester,
  ) async {
    var exited = false;
    await _pump(
      tester,
      initialChapter: 'chapter-2',
      onExit: () => exited = true,
    );
    expect(find.byKey(const Key('manga-vertical-reader')), findsOneWidget);
    expect(find.text('2 / 3'), findsOneWidget);
    await tester.tap(find.byKey(const Key('manga-reader-exit')));
    expect(exited, isTrue);
  });

  testWidgets('switches modes without losing the corresponding page', (
    tester,
  ) async {
    await _pump(tester, initialChapter: 'chapter-2');
    await tester.tap(find.byKey(const Key('manga-reader-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('横向单页'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('manga-horizontal-reader')), findsOneWidget);
    expect(find.text('2 / 3'), findsOneWidget);

    await tester.tap(find.byKey(const Key('manga-reader-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('从右到左'));
    await tester.pumpAndSettle();
    final pageView = tester.widget<PageView>(
      find.byKey(const Key('manga-horizontal-reader')),
    );
    expect(pageView.reverse, isTrue);
  });

  testWidgets('a failed page shows a placeholder without blocking the reader', (
    tester,
  ) async {
    await _pump(tester, repository: _Repository(failPageId: 'page-1'));
    await tester.pumpAndSettle();
    expect(find.text('此页无法显示'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester, {
  String? initialChapter,
  VoidCallback? onExit,
  _Repository repository = const _Repository(),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mangaReaderRepositoryProvider.overrideWithValue(repository),
        readingProgressRepositoryProvider.overrideWithValue(
          _ProgressRepository(),
        ),
        mangaReaderPreferenceRepositoryProvider.overrideWithValue(
          _PreferenceRepository(),
        ),
      ],
      child: MaterialApp(
        home: MangaReaderPage(
          mediaItemId: 'media',
          initialContentUnitId: initialChapter,
          onExit: onExit ?? () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final class _Repository implements MangaReaderRepository {
  const _Repository({this.failPageId});
  final String? failPageId;
  @override
  Future<MangaReaderBook?> loadBook(String mediaItemId) async => _book;
  @override
  Future<Uint8List> readPage(String mediaItemId, MangaPage page) async {
    if (page.id == failPageId) throw StateError('broken');
    return generatedMangaPng();
  }
}

final class _ProgressRepository implements ReadingProgressRepository {
  ReadingProgress? value;
  @override
  Future<ReadingProgress?> findForMedia(String mediaItemId) async => value;
  @override
  Future<ProgressWriteResult> save(ReadingProgress progress) async {
    value = progress;
    return progress.revision == 0
        ? ProgressWriteResult.inserted
        : ProgressWriteResult.updated;
  }
}

final class _PreferenceRepository implements MangaReaderPreferenceRepository {
  MangaReaderPreference? value;
  @override
  Future<MangaReaderPreference?> findForMedia(String mediaItemId) async =>
      value;
  @override
  Future<void> save(MangaReaderPreference preference) async {
    value = preference;
  }
}

final _book = MangaReaderBook(
  mediaItem: MediaItem(
    id: 'media',
    mediaType: MediaType.manga,
    title: '漫画',
    createdAt: DateTime.utc(2026, 8, 15),
    updatedAt: DateTime.utc(2026, 8, 15),
  ),
  chapters: [
    MangaReaderChapter(
      unit: _chapter('chapter-1', 0),
      pages: [_page('page-1', 'chapter-1', 0)],
    ),
    MangaReaderChapter(
      unit: _chapter('chapter-2', 1),
      pages: [_page('page-2', 'chapter-2', 0), _page('page-3', 'chapter-2', 1)],
    ),
  ],
);
ContentUnit _chapter(String id, int order) => ContentUnit(
  id: id,
  mediaItemId: 'media',
  unitType: ContentUnitType.chapter,
  title: '第 ${order + 1} 话',
  orderIndex: order,
  contentRef: 'chapter/$order',
  sourceLocator: '$order',
  contentHash: 'hash-$order',
);
MangaPage _page(String id, String chapter, int order) => MangaPage(
  id: id,
  contentUnitId: chapter,
  orderIndex: order,
  contentRef: id,
  sourceLocator: '$id.png',
  contentHash: 'hash-$id',
  imageType: MangaImageType.png,
  byteLength: 1,
  pixelWidth: 1,
  pixelHeight: 1,
);
