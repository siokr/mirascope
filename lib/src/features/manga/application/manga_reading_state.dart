import '../../../core/ids/id_generator.dart';
import '../../novel/domain/progress_write_result.dart';
import '../../novel/domain/reading_progress.dart';
import '../../novel/domain/reading_progress_repository.dart';
import '../domain/manga_progress_locator.dart';
import '../domain/manga_reader_book.dart';
import '../domain/manga_reader_preference.dart';
import '../domain/manga_reader_preference_repository.dart';

typedef MangaReaderClock = DateTime Function();

final class MangaReadingState {
  MangaReadingState({
    required this.mediaItemId,
    required this.book,
    required this.progressRepository,
    required this.preferenceRepository,
    required this.idGenerator,
    required this.clock,
    this.initialContentUnitId,
  });

  final String mediaItemId;
  final MangaReaderBook book;
  final ReadingProgressRepository progressRepository;
  final MangaReaderPreferenceRepository preferenceRepository;
  final IdGenerator idGenerator;
  final MangaReaderClock clock;
  final String? initialContentUnitId;

  int currentPageIndex = 0;
  double intraPageFraction = 0;
  MangaReadingMode mode = MangaReadingMode.vertical;
  PageTurnDirection direction = PageTurnDirection.leftToRight;
  ReadingProgress? _storedProgress;
  MangaReaderPreference? _storedPreference;
  Future<void> _queue = Future.value();

  Future<void> initialize() async {
    _storedProgress = await progressRepository.findForMedia(mediaItemId);
    _storedPreference = await preferenceRepository.findForMedia(mediaItemId);
    mode = _storedPreference?.readingMode ?? MangaReadingMode.vertical;
    direction =
        _storedPreference?.pageTurnDirection ?? PageTurnDirection.leftToRight;
    final requested = initialContentUnitId;
    if (requested != null) {
      final index = book.pages.indexWhere(
        (page) => page.contentUnitId == requested,
      );
      if (index >= 0) currentPageIndex = index;
      intraPageFraction = 0;
      return;
    }
    final progress = _storedProgress;
    if (progress == null) return;
    final chapterStart = book.pages.indexWhere(
      (page) => page.contentUnitId == progress.contentUnitId,
    );
    if (chapterStart < 0) return;
    final locator = MangaProgressLocator.tryParse(progress.locator);
    if (locator == null) return;
    final chapterPages = book.pages
        .where((page) => page.contentUnitId == progress.contentUnitId)
        .length;
    currentPageIndex =
        chapterStart + locator.pageIndex.clamp(0, chapterPages - 1);
    intraPageFraction = locator.intraPageFraction;
  }

  void updatePage(int globalPageIndex, {double fraction = 0}) {
    currentPageIndex = globalPageIndex.clamp(0, book.pages.length - 1);
    intraPageFraction = fraction.clamp(0.0, 1.0);
  }

  Future<void> setPreference(
    MangaReadingMode readingMode,
    PageTurnDirection pageDirection,
  ) async {
    mode = readingMode;
    direction = pageDirection;
    final snapshot = MangaReaderPreference(
      id: _storedPreference?.id ?? idGenerator.newId(),
      mediaItemId: mediaItemId,
      readingMode: mode,
      pageTurnDirection: direction,
      updatedAt: clock().toUtc(),
    );
    _storedPreference = snapshot;
    _queue = _queue.then((_) => preferenceRepository.save(snapshot));
    await _queue;
  }

  Future<void> flushProgress() async {
    final page = book.pages[currentPageIndex];
    final chapterPages = book.pages
        .where((value) => value.contentUnitId == page.contentUnitId)
        .toList();
    final pageIndex = chapterPages.indexWhere((value) => value.id == page.id);
    final previous = _storedProgress;
    final snapshot = ReadingProgress(
      id: previous?.id ?? idGenerator.newId(),
      mediaItemId: mediaItemId,
      contentUnitId: page.contentUnitId,
      locator: MangaProgressLocator(
        pageIndex: pageIndex,
        intraPageFraction: intraPageFraction,
      ).encode(),
      fraction: book.pages.length <= 1
          ? 0
          : currentPageIndex / (book.pages.length - 1),
      updatedAt: clock().toUtc(),
      revision: previous == null ? 0 : previous.revision + 1,
    );
    _queue = _queue.then((_) => _writeProgress(snapshot));
    await _queue;
  }

  Future<void> _writeProgress(ReadingProgress snapshot) async {
    final result = await progressRepository.save(snapshot);
    if (result != ProgressWriteResult.revisionConflict) {
      _storedProgress = snapshot;
      return;
    }
    final latest = await progressRepository.findForMedia(mediaItemId);
    if (latest == null || latest.updatedAt.isAfter(snapshot.updatedAt)) return;
    final retry = ReadingProgress(
      id: latest.id,
      mediaItemId: snapshot.mediaItemId,
      contentUnitId: snapshot.contentUnitId,
      locator: snapshot.locator,
      fraction: snapshot.fraction,
      updatedAt: snapshot.updatedAt,
      revision: latest.revision + 1,
    );
    if (await progressRepository.save(retry) !=
        ProgressWriteResult.revisionConflict) {
      _storedProgress = retry;
    }
  }
}
