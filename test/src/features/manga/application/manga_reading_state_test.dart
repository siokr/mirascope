import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/ids/id_generator.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/manga/application/manga_reading_state.dart';
import 'package:mirascope/src/features/manga/domain/manga_page.dart';
import 'package:mirascope/src/features/manga/domain/manga_reader_book.dart';
import 'package:mirascope/src/features/manga/domain/manga_reader_preference.dart';
import 'package:mirascope/src/features/manga/domain/manga_reader_preference_repository.dart';
import 'package:mirascope/src/features/novel/domain/content_unit.dart';
import 'package:mirascope/src/features/novel/domain/progress_write_result.dart';
import 'package:mirascope/src/features/novel/domain/reading_progress.dart';
import 'package:mirascope/src/features/novel/domain/reading_progress_repository.dart';

void main() {
  test('restores chapter page fraction and reader preference', () async {
    final progress = _ProgressRepository(
      initial: ReadingProgress(
        id: 'progress',
        mediaItemId: 'media',
        contentUnitId: 'chapter-2',
        locator: 'page:1:0.250000',
        fraction: .9,
        updatedAt: _now,
        revision: 3,
      ),
    );
    final preferences = _PreferenceRepository(
      initial: MangaReaderPreference(
        id: 'preference',
        mediaItemId: 'media',
        readingMode: MangaReadingMode.horizontal,
        pageTurnDirection: PageTurnDirection.rightToLeft,
        updatedAt: _now,
      ),
    );
    final state = _state(progress, preferences);
    await state.initialize();
    expect(state.currentPageIndex, 2);
    expect(state.intraPageFraction, .25);
    expect(state.mode, MangaReadingMode.horizontal);
    expect(state.direction, PageTurnDirection.rightToLeft);
  });

  test('requested chapter overrides stored progress', () async {
    final state = _state(
      _ProgressRepository(
        initial: ReadingProgress(
          id: 'p',
          mediaItemId: 'media',
          contentUnitId: 'chapter-2',
          locator: 'page:1:0.5',
          fraction: 1,
          updatedAt: _now,
          revision: 1,
        ),
      ),
      _PreferenceRepository(),
      initialChapter: 'chapter-1',
    );
    await state.initialize();
    expect(state.currentPageIndex, 0);
    expect(state.intraPageFraction, 0);
  });

  test('saves semantic page locator and preferences', () async {
    final progress = _ProgressRepository();
    final preferences = _PreferenceRepository();
    final state = _state(progress, preferences);
    await state.initialize();
    state.updatePage(2, fraction: .4);
    await state.setPreference(
      MangaReadingMode.horizontal,
      PageTurnDirection.rightToLeft,
    );
    await state.flushProgress();
    expect(progress.saved.single.contentUnitId, 'chapter-2');
    expect(progress.saved.single.locator, 'page:1:0.400000');
    expect(preferences.saved.single.readingMode, MangaReadingMode.horizontal);
  });

  test('a newer conflicting write is never overwritten', () async {
    final newer = ReadingProgress(
      id: 'new',
      mediaItemId: 'media',
      contentUnitId: 'chapter-2',
      locator: 'page:1:0.9',
      fraction: 1,
      updatedAt: _now.add(const Duration(minutes: 1)),
      revision: 9,
    );
    final progress = _ProgressRepository(initial: newer, conflict: true);
    final state = _state(progress, _PreferenceRepository());
    await state.initialize();
    state.updatePage(0);
    await state.flushProgress();
    expect(progress.saved, hasLength(1));
  });
}

MangaReadingState _state(
  _ProgressRepository progress,
  _PreferenceRepository preferences, {
  String? initialChapter,
}) => MangaReadingState(
  mediaItemId: 'media',
  book: _book,
  progressRepository: progress,
  preferenceRepository: preferences,
  idGenerator: _Ids(),
  clock: () => _now,
  initialContentUnitId: initialChapter,
);

final _now = DateTime.utc(2026, 8, 15, 12);
final _book = MangaReaderBook(
  mediaItem: MediaItem(
    id: 'media',
    mediaType: MediaType.manga,
    title: '漫画',
    createdAt: _now,
    updatedAt: _now,
  ),
  chapters: [
    MangaReaderChapter(
      unit: _chapter('chapter-1', 0),
      pages: [_page('p1', 'chapter-1', 0)],
    ),
    MangaReaderChapter(
      unit: _chapter('chapter-2', 1),
      pages: [_page('p2', 'chapter-2', 0), _page('p3', 'chapter-2', 1)],
    ),
  ],
);
ContentUnit _chapter(String id, int order) => ContentUnit(
  id: id,
  mediaItemId: 'media',
  unitType: ContentUnitType.chapter,
  title: id,
  orderIndex: order,
  contentRef: id,
  sourceLocator: id,
  contentHash: id,
);
MangaPage _page(String id, String chapter, int order) => MangaPage(
  id: id,
  contentUnitId: chapter,
  orderIndex: order,
  contentRef: id,
  sourceLocator: id,
  contentHash: id,
  imageType: MangaImageType.png,
  byteLength: 1,
);

final class _ProgressRepository implements ReadingProgressRepository {
  _ProgressRepository({this.initial, this.conflict = false});
  ReadingProgress? initial;
  final bool conflict;
  final saved = <ReadingProgress>[];
  @override
  Future<ReadingProgress?> findForMedia(String mediaItemId) async => initial;
  @override
  Future<ProgressWriteResult> save(ReadingProgress progress) async {
    saved.add(progress);
    if (conflict) return ProgressWriteResult.revisionConflict;
    initial = progress;
    return progress.revision == 0
        ? ProgressWriteResult.inserted
        : ProgressWriteResult.updated;
  }
}

final class _PreferenceRepository implements MangaReaderPreferenceRepository {
  _PreferenceRepository({this.initial});
  MangaReaderPreference? initial;
  final saved = <MangaReaderPreference>[];
  @override
  Future<MangaReaderPreference?> findForMedia(String mediaItemId) async =>
      initial;
  @override
  Future<void> save(MangaReaderPreference preference) async {
    saved.add(preference);
    initial = preference;
  }
}

final class _Ids implements IdGenerator {
  var value = 0;
  @override
  String newId() => 'id-${value++}';
}
