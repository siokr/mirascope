import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/novel/domain/content_unit.dart';
import 'package:mirascope/src/features/novel/domain/novel_details.dart';
import 'package:mirascope/src/features/novel/domain/novel_details_repository.dart';
import 'package:mirascope/src/features/novel/presentation/novel_details_page.dart';

void main() {
  testWidgets('shows title, ordered directory and opens reader', (
    tester,
  ) async {
    var opened = false;
    String? openedChapter;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelDetailsRepositoryProvider.overrideWithValue(
            _Repository(_details(sourceAvailable: true)),
          ),
        ],
        child: MaterialApp(
          home: NovelDetailsPage(
            mediaItemId: 'media-1',
            onStartReading: (chapterId) {
              opened = true;
              openedChapter = chapterId;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Book'), findsOneWidget);
    expect(find.text('共 2 章'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    await tester.tap(find.text('开始阅读'));
    expect(opened, isTrue);
    expect(openedChapter, isNull);

    opened = false;
    await tester.tap(find.text('Second'));
    expect(opened, isTrue);
    expect(openedChapter, 'unit-2');
  });

  testWidgets('missing source preserves directory and offers relocation', (
    tester,
  ) async {
    var relocated = false;
    var opened = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelDetailsRepositoryProvider.overrideWithValue(
            _Repository(_details(sourceAvailable: false)),
          ),
        ],
        child: MaterialApp(
          home: NovelDetailsPage(
            mediaItemId: 'media-1',
            onStartReading: (_) => opened = true,
            onRelocateSource: () => relocated = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('源文件已移动或不可用，请重新定位。'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
    expect(find.text('开始阅读'), findsOneWidget);
    await tester.tap(find.text('开始阅读'));
    expect(opened, isTrue);
    await tester.tap(find.text('重新定位源文件'));
    expect(relocated, isTrue);
  });
}

NovelDetails _details({required bool sourceAvailable}) {
  final now = DateTime.utc(2026, 7, 29);
  return NovelDetails(
    mediaItem: MediaItem(
      id: 'media-1',
      mediaType: MediaType.novel,
      title: 'Book',
      createdAt: now,
      updatedAt: now,
    ),
    chapters: [_chapter('unit-1', 'First', 0), _chapter('unit-2', 'Second', 1)],
    sourceAvailable: sourceAvailable,
  );
}

ContentUnit _chapter(String id, String title, int order) => ContentUnit(
  id: id,
  mediaItemId: 'media-1',
  unitType: ContentUnitType.chapter,
  title: title,
  orderIndex: order,
  contentRef: 'content/book.txt',
  sourceLocator: 'txt-v1:0:0:1',
  contentHash: 'hash-$id',
);

final class _Repository implements NovelDetailsRepository {
  const _Repository(this.details);
  final NovelDetails? details;

  @override
  Future<NovelDetails?> findDetails(String mediaItemId) async => details;
}
