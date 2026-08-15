import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/importing/domain/import_record.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/manga/domain/manga_details.dart';
import 'package:mirascope/src/features/manga/domain/manga_details_repository.dart';
import 'package:mirascope/src/features/manga/presentation/manga_details_page.dart';
import 'package:mirascope/src/features/novel/domain/content_unit.dart';

void main() {
  testWidgets('shows stable chapter order and page counts', (tester) async {
    String? opened;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mangaDetailsRepositoryProvider.overrideWithValue(
            _Repository(_details(true)),
          ),
        ],
        child: MaterialApp(
          home: MangaDetailsPage(
            mediaItemId: 'media',
            onOpenChapter: (id) => opened = id,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('漫画'), findsOneWidget);
    expect(find.text('共 2 章 · 5 页'), findsOneWidget);
    expect(find.text('第一话'), findsOneWidget);
    expect(find.text('3 页'), findsOneWidget);
    await tester.tap(find.text('第二话'));
    expect(opened, 'chapter-2');
  });

  testWidgets('missing source preserves but disables the directory', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mangaDetailsRepositoryProvider.overrideWithValue(
            _Repository(_details(false)),
          ),
        ],
        child: MaterialApp(
          home: MangaDetailsPage(
            mediaItemId: 'media',
            onOpenChapter: (_) => opened = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('源文件已移动'), findsOneWidget);
    expect(find.text('第一话'), findsOneWidget);
    await tester.tap(find.text('第一话'));
    expect(opened, isFalse);
  });
}

MangaDetails _details(bool available) {
  final now = DateTime.utc(2026, 8, 15);
  return MangaDetails(
    mediaItem: MediaItem(
      id: 'media',
      mediaType: MediaType.manga,
      title: '漫画',
      createdAt: now,
      updatedAt: now,
    ),
    chapters: [
      MangaChapterDetails(unit: _chapter('chapter-1', '第一话', 0), pageCount: 3),
      MangaChapterDetails(unit: _chapter('chapter-2', '第二话', 1), pageCount: 2),
    ],
    sourceAvailable: available,
    sourceKind: ImportSourceKind.mangaArchive,
  );
}

ContentUnit _chapter(String id, String title, int order) => ContentUnit(
  id: id,
  mediaItemId: 'media',
  unitType: ContentUnitType.chapter,
  title: title,
  orderIndex: order,
  contentRef: 'manga/media/$order',
  sourceLocator: title,
  contentHash: 'hash-$order',
);

final class _Repository implements MangaDetailsRepository {
  const _Repository(this.value);
  final MangaDetails value;
  @override
  Future<MangaDetails?> findDetails(String mediaItemId) async => value;
}
