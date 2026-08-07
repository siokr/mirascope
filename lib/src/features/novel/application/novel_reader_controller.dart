import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/ids/id_generator.dart';
import '../domain/novel_reader_repository.dart';
import '../domain/progress_write_result.dart';
import '../domain/reader_book.dart';
import '../domain/reading_progress.dart';
import '../domain/reading_progress_repository.dart';

typedef ReaderClock = DateTime Function();

final class NovelReaderController extends ChangeNotifier {
  NovelReaderController({
    required this.mediaItemId,
    required this.repository,
    this.initialContentUnitId,
    this.progressRepository,
    this.idGenerator,
    this.clock,
    this.saveDebounce = const Duration(milliseconds: 750),
  });

  final String mediaItemId;
  final NovelReaderRepository repository;
  final String? initialContentUnitId;
  final ReadingProgressRepository? progressRepository;
  final IdGenerator? idGenerator;
  final ReaderClock? clock;
  final Duration saveDebounce;

  ReaderBook? book;
  ReaderChapter? chapter;
  int currentIndex = 0;
  int? loadingIndex;
  int? retryIndex;
  String? errorMessage;
  bool initialLoading = true;
  int restoredCharacterOffset = 0;
  double restoredFraction = 0;
  ReadingProgress? _storedProgress;
  _PendingProgress? _pendingProgress;
  Timer? _saveTimer;
  Future<void> _saveQueue = Future.value();

  bool get canGoPrevious => currentIndex > 0 && loadingIndex == null;
  bool get canGoNext =>
      book != null &&
      currentIndex + 1 < book!.chapters.length &&
      loadingIndex == null;

  Future<void> initialize() async {
    try {
      book = await repository.loadBook(mediaItemId);
      if (book == null || book!.chapters.isEmpty) {
        errorMessage = '无法打开这部作品';
        return;
      }
      _storedProgress = await progressRepository?.findForMedia(mediaItemId);
      final requestedIndex = initialContentUnitId == null
          ? -1
          : book!.chapters.indexWhere(
              (unit) => unit.id == initialContentUnitId,
            );
      final restoredIndex = _storedProgress == null
          ? 0
          : book!.chapters.indexWhere(
              (unit) => unit.id == _storedProgress!.contentUnitId,
            );
      await _load(
        requestedIndex >= 0
            ? requestedIndex
            : (restoredIndex < 0 ? 0 : restoredIndex),
      );
      if (requestedIndex >= 0) {
        restoredCharacterOffset = 0;
        restoredFraction = 0;
        updatePosition(characterOffset: 0, fraction: 0);
        await flushProgress();
      } else {
        restoredCharacterOffset = _restoreOffset(
          _storedProgress,
          chapter!.text.length,
        );
        restoredFraction = _restoreFraction(_storedProgress, chapter!);
      }
    } on Object {
      errorMessage = '无法加载阅读内容';
    } finally {
      initialLoading = false;
      notifyListeners();
    }
  }

  Future<void> previous() => select(currentIndex - 1);
  Future<void> next() => select(currentIndex + 1);

  Future<void> select(int index) async {
    final chapters = book?.chapters;
    if (chapters == null ||
        index < 0 ||
        index >= chapters.length ||
        index == currentIndex ||
        loadingIndex != null) {
      return;
    }
    await flushProgress();
    await _load(index);
    if (currentIndex == index && chapter != null) {
      restoredCharacterOffset = 0;
      restoredFraction = 0;
      updatePosition(characterOffset: 0, fraction: 0);
      await flushProgress();
    }
  }

  Future<void> retry() async {
    if (chapter == null) {
      initialLoading = true;
      errorMessage = null;
      notifyListeners();
      await initialize();
    } else {
      await _load(retryIndex ?? currentIndex);
    }
  }

  Future<void> _load(int index) async {
    loadingIndex = index;
    errorMessage = null;
    notifyListeners();
    try {
      final loaded = await repository.readChapter(book!.chapters[index]);
      chapter = loaded;
      currentIndex = index;
      retryIndex = null;
    } on Object {
      retryIndex = index;
      errorMessage = '无法读取所选章节';
    } finally {
      loadingIndex = null;
      notifyListeners();
    }
  }

  void updatePosition({
    required int characterOffset,
    required double fraction,
  }) {
    if (progressRepository == null ||
        idGenerator == null ||
        clock == null ||
        chapter == null) {
      return;
    }
    final safeOffset = characterOffset.clamp(0, chapter!.text.length);
    final safeFraction = fraction.clamp(0.0, 1.0);
    _pendingProgress = _PendingProgress(
      contentUnitId: chapter!.unit.id,
      characterOffset: safeOffset,
      fraction: safeFraction,
    );
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDebounce, () {
      unawaited(flushProgress());
    });
  }

  Future<void> flushProgress() async {
    _saveTimer?.cancel();
    _saveTimer = null;
    final pending = _pendingProgress;
    if (pending == null ||
        progressRepository == null ||
        idGenerator == null ||
        clock == null) {
      return;
    }
    _pendingProgress = null;
    _saveQueue = _saveQueue.then((_) => _writeProgress(pending));
    await _saveQueue;
  }

  Future<void> _writeProgress(_PendingProgress pending) async {
    final previous = _storedProgress;
    final progress = ReadingProgress(
      id: previous?.id ?? idGenerator!.newId(),
      mediaItemId: mediaItemId,
      contentUnitId: pending.contentUnitId,
      locator: _progressLocator(pending),
      fraction: pending.fraction,
      updatedAt: clock!().toUtc(),
      revision: previous == null ? 0 : previous.revision + 1,
    );
    final result = await progressRepository!.save(progress);
    if (result == ProgressWriteResult.revisionConflict) {
      _storedProgress = await progressRepository!.findForMedia(mediaItemId);
      final current = _storedProgress;
      if (current != null) {
        final retry = ReadingProgress(
          id: current.id,
          mediaItemId: mediaItemId,
          contentUnitId: pending.contentUnitId,
          locator: _progressLocator(pending),
          fraction: pending.fraction,
          updatedAt: clock!().toUtc(),
          revision: current.revision + 1,
        );
        final retryResult = await progressRepository!.save(retry);
        if (retryResult != ProgressWriteResult.revisionConflict) {
          _storedProgress = retry;
        }
      }
      return;
    }
    _storedProgress = progress;
  }

  int _restoreOffset(ReadingProgress? progress, int textLength) {
    if (progress == null) return 0;
    final match = RegExp(r'^char-v1:(\d+)$').firstMatch(progress.locator);
    if (match != null) {
      return int.parse(match.group(1)!).clamp(0, textLength);
    }
    if (progress.fraction.isFinite &&
        progress.fraction >= 0 &&
        progress.fraction <= 1) {
      return (textLength * progress.fraction).round().clamp(0, textLength);
    }
    return 0;
  }

  double _restoreFraction(ReadingProgress? progress, ReaderChapter chapter) {
    if (progress == null) return 0;
    // The stored fraction represents the exact scroll position for the
    // current immutable derived chapter. Prefer it for ordinary reopen and
    // app-restart restoration; the semantic locator remains a safe fallback
    // for legacy or otherwise invalid display progress.
    if (progress.fraction.isFinite &&
        progress.fraction >= 0 &&
        progress.fraction <= 1) {
      return progress.fraction;
    }
    final blockMatch = RegExp(
      r'^epub-block-v1:(\d+):(\d+)$',
    ).firstMatch(progress.locator);
    if (blockMatch != null && chapter.blocks.isNotEmpty) {
      final index = int.parse(
        blockMatch.group(1)!,
      ).clamp(0, chapter.blocks.length - 1);
      final block = chapter.blocks[index];
      final offset = int.parse(blockMatch.group(2)!);
      final withinBlock = block.text == null || block.text!.isEmpty
          ? 0.0
          : offset.clamp(0, block.text!.length) / block.text!.length;
      return ((index + withinBlock) / chapter.blocks.length).clamp(0.0, 1.0);
    }
    return 0;
  }

  String _progressLocator(_PendingProgress pending) => chapter!.progressLocator(
    characterOffset: pending.characterOffset,
    fraction: pending.fraction,
  );

  Future<void> close() async {
    _saveTimer?.cancel();
    await flushProgress();
  }
}

final class _PendingProgress {
  const _PendingProgress({
    required this.contentUnitId,
    required this.characterOffset,
    required this.fraction,
  });

  final String contentUnitId;
  final int characterOffset;
  final double fraction;
}
