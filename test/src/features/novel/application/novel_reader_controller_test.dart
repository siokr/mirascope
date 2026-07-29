import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/novel/application/novel_reader_controller.dart';
import 'package:mirascope/src/features/novel/domain/content_unit.dart';
import 'package:mirascope/src/features/novel/domain/novel_reader_repository.dart';
import 'package:mirascope/src/features/novel/domain/reader_book.dart';

void main() {
  test('keeps the current readable chapter when switching fails', () async {
    final repository = _ReaderRepository(failSecond: true);
    final controller = NovelReaderController(
      mediaItemId: 'media-1',
      repository: repository,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    expect(controller.chapter?.text, 'Body 1');
    expect(controller.canGoPrevious, isFalse);
    expect(controller.canGoNext, isTrue);

    await controller.next();

    expect(controller.currentIndex, 0);
    expect(controller.chapter?.text, 'Body 1');
    expect(controller.errorMessage, '无法读取所选章节');
  });

  test('successful navigation updates boundaries', () async {
    final controller = NovelReaderController(
      mediaItemId: 'media-1',
      repository: _ReaderRepository(),
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    await controller.next();

    expect(controller.currentIndex, 1);
    expect(controller.chapter?.text, 'Body 2');
    expect(controller.canGoPrevious, isTrue);
    expect(controller.canGoNext, isFalse);
  });
}

final class _ReaderRepository implements NovelReaderRepository {
  _ReaderRepository({this.failSecond = false});
  final bool failSecond;
  final book = _book();

  @override
  Future<ReaderBook?> loadBook(String mediaItemId) async => book;

  @override
  Future<ReaderChapter> readChapter(ContentUnit unit) async {
    if (failSecond && unit.orderIndex == 1) throw StateError('failed');
    return ReaderChapter(unit: unit, text: 'Body ${unit.orderIndex + 1}');
  }
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
