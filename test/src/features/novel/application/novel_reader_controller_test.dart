import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/ids/id_generator.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/novel/application/novel_reader_controller.dart';
import 'package:mirascope/src/features/novel/domain/content_unit.dart';
import 'package:mirascope/src/features/novel/domain/novel_reader_repository.dart';
import 'package:mirascope/src/features/novel/domain/reader_book.dart';
import 'package:mirascope/src/features/novel/domain/progress_write_result.dart';
import 'package:mirascope/src/features/novel/domain/reading_progress.dart';
import 'package:mirascope/src/features/novel/domain/reading_progress_repository.dart';

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

  test('restores the saved chapter and semantic character offset', () async {
    final progress = _ProgressRepository(
      stored: ReadingProgress(
        id: 'progress-1',
        mediaItemId: 'media-1',
        contentUnitId: 'unit-1',
        locator: 'char-v1:4',
        fraction: 0.2,
        updatedAt: DateTime.utc(2026, 7, 29),
        revision: 3,
      ),
    );
    final controller = NovelReaderController(
      mediaItemId: 'media-1',
      repository: _ReaderRepository(),
      progressRepository: progress,
      idGenerator: _Ids(),
      clock: () => DateTime.utc(2026, 7, 29),
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.currentIndex, 1);
    expect(controller.chapter?.text, 'Body 2');
    expect(controller.restoredCharacterOffset, 4);
  });

  test('explicit chapter selection overrides stored progress', () async {
    final progress = _ProgressRepository(
      stored: ReadingProgress(
        id: 'progress-1',
        mediaItemId: 'media-1',
        contentUnitId: 'unit-1',
        locator: 'char-v1:4',
        fraction: 0.5,
        updatedAt: DateTime.utc(2026, 7, 29),
        revision: 2,
      ),
    );
    final controller = NovelReaderController(
      mediaItemId: 'media-1',
      initialContentUnitId: 'unit-0',
      repository: _ReaderRepository(),
      progressRepository: progress,
      idGenerator: _Ids(),
      clock: () => DateTime.utc(2026, 7, 30),
      saveDebounce: Duration.zero,
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.currentIndex, 0);
    expect(controller.chapter?.unit.id, 'unit-0');
    expect(controller.restoredCharacterOffset, 0);
    expect(progress.saved.last.contentUnitId, 'unit-0');
  });

  test('missing chapter and invalid locator fall back safely', () async {
    final progress = _ProgressRepository(
      stored: ReadingProgress(
        id: 'progress-1',
        mediaItemId: 'media-1',
        contentUnitId: 'removed-unit',
        locator: 'invalid',
        fraction: 0.5,
        updatedAt: DateTime.utc(2026, 7, 29),
        revision: 3,
      ),
    );
    final controller = NovelReaderController(
      mediaItemId: 'media-1',
      repository: _ReaderRepository(),
      progressRepository: progress,
      idGenerator: _Ids(),
      clock: () => DateTime.utc(2026, 7, 29),
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.currentIndex, 0);
    expect(controller.restoredCharacterOffset, 3);
  });

  test('debounce saves only the newest pending position', () async {
    final progress = _ProgressRepository();
    final controller = NovelReaderController(
      mediaItemId: 'media-1',
      repository: _ReaderRepository(),
      progressRepository: progress,
      idGenerator: _Ids(),
      clock: () => DateTime.utc(2026, 7, 29),
      saveDebounce: const Duration(milliseconds: 10),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    controller.updatePosition(characterOffset: 2, fraction: 0.2);
    controller.updatePosition(characterOffset: 5, fraction: 0.5);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await controller.flushProgress();

    expect(progress.saved, hasLength(1));
    expect(progress.saved.single.locator, 'char-v1:5');
    expect(progress.saved.single.fraction, 0.5);
  });

  test(
    'revision conflict reloads and retries above the stored revision',
    () async {
      final progress = _ProgressRepository(
        stored: ReadingProgress(
          id: 'progress-1',
          mediaItemId: 'media-1',
          contentUnitId: 'unit-0',
          locator: 'char-v1:1',
          fraction: 0.1,
          updatedAt: DateTime.utc(2026, 7, 29),
          revision: 5,
        ),
        conflictOnce: true,
      );
      final controller = NovelReaderController(
        mediaItemId: 'media-1',
        repository: _ReaderRepository(),
        progressRepository: progress,
        idGenerator: _Ids(),
        clock: () => DateTime.utc(2026, 7, 29),
      );
      addTearDown(controller.dispose);
      await controller.initialize();

      controller.updatePosition(characterOffset: 4, fraction: 0.4);
      await controller.flushProgress();

      expect(progress.saved.last.revision, 6);
      expect(progress.saved.last.locator, 'char-v1:4');
    },
  );
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

final class _Ids implements IdGenerator {
  var value = 0;
  @override
  String newId() => 'progress-${value++}';
}

final class _ProgressRepository implements ReadingProgressRepository {
  _ProgressRepository({this.stored, this.conflictOnce = false});

  ReadingProgress? stored;
  bool conflictOnce;
  final saved = <ReadingProgress>[];

  @override
  Future<ReadingProgress?> findForMedia(String mediaItemId) async => stored;

  @override
  Future<ProgressWriteResult> save(ReadingProgress progress) async {
    saved.add(progress);
    if (conflictOnce) {
      conflictOnce = false;
      return ProgressWriteResult.revisionConflict;
    }
    final result = stored == null
        ? ProgressWriteResult.inserted
        : ProgressWriteResult.updated;
    stored = progress;
    return result;
  }
}
