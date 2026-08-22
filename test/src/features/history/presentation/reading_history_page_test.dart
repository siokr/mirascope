import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/history/domain/library_statistics.dart';
import 'package:mirascope/src/features/history/domain/reading_history_item.dart';
import 'package:mirascope/src/features/history/domain/reading_history_repository.dart';
import 'package:mirascope/src/features/history/presentation/reading_history_page.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';

void main() {
  testWidgets('opens manga history with the manga callback', (tester) async {
    String? openedManga;
    String? openedNovel;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readingHistoryRepositoryProvider.overrideWithValue(
            const _Repository(),
          ),
        ],
        child: MaterialApp(
          home: ReadingHistoryPage(
            onOpenNovel: (id) => openedNovel = id,
            onOpenManga: (id) => openedManga = id,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('history-manga')));

    expect(openedManga, 'manga');
    expect(openedNovel, isNull);
  });
}

final class _Repository implements ReadingHistoryRepository {
  const _Repository();

  @override
  Stream<List<ReadingHistoryItem>> watchRecent({int limit = 50}) =>
      Stream.value([
        ReadingHistoryItem(
          mediaItemId: 'manga',
          title: '漫画',
          mediaType: MediaType.manga,
          lastOpenedAt: DateTime.utc(2026, 8, 22),
        ),
      ]);

  @override
  Stream<LibraryStatistics> watchStatistics() => Stream.value(
    const LibraryStatistics(
      totalMedia: 1,
      startedMedia: 0,
      favoriteMedia: 0,
      novelMedia: 0,
      mangaMedia: 1,
    ),
  );
}
