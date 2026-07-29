import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/novel/application/novel_providers.dart';
import 'package:mirascope/src/features/novel/domain/content_unit.dart';
import 'package:mirascope/src/features/novel/domain/novel_reader_repository.dart';
import 'package:mirascope/src/features/novel/domain/reader_book.dart';
import 'package:mirascope/src/features/novel/presentation/novel_reader_page.dart';

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
