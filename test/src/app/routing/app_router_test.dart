import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mirascope/src/app/app.dart';
import 'package:mirascope/src/app/routing/app_router.dart';
import 'package:mirascope/src/app/routing/app_routes.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/novel/domain/content_unit.dart';
import 'package:mirascope/src/features/novel/domain/novel_details.dart';
import 'package:mirascope/src/features/novel/domain/novel_details_repository.dart';
import 'package:mirascope/src/features/novel/domain/novel_reader_repository.dart';
import 'package:mirascope/src/features/novel/domain/reader_book.dart';
import 'package:mirascope/src/features/novel/domain/progress_write_result.dart';
import 'package:mirascope/src/features/novel/domain/reading_progress.dart';
import 'package:mirascope/src/features/novel/domain/reading_progress_repository.dart';
import 'package:mirascope/src/features/settings/domain/effective_reader_preference.dart';
import 'package:mirascope/src/features/settings/domain/reader_preference.dart';
import 'package:mirascope/src/features/settings/domain/reader_preference_repository.dart';
import 'package:mirascope/src/features/novel/application/novel_providers.dart';

import '../../features/library/library_test_support.dart';

void main() {
  testWidgets('opens settings from the library', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final repository = FakeMediaLibraryRepository();
    addTearDown(() {
      repository.close();
    });

    await _pumpApp(tester, router, repository);
    expect(find.text('媒体库'), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-settings')));
    await _pumpRoute(tester);

    expect(find.text('设置'), findsOneWidget);

    await tester.pageBack();
    await _pumpRoute(tester);

    expect(find.text('媒体库'), findsOneWidget);
  });

  testWidgets('opens the archived library and returns', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final repository = FakeMediaLibraryRepository();
    addTearDown(() {
      repository.close();
    });

    await _pumpApp(tester, router, repository);
    await tester.tap(find.byKey(const Key('open-archive')));
    repository.archivedController.add([]);
    await _pumpRoute(tester);

    expect(find.text('已归档'), findsOneWidget);

    await tester.pageBack();
    await _pumpRoute(tester);
    expect(find.text('媒体库'), findsOneWidget);
  });

  testWidgets('opens novel details with the media id', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final repository = FakeMediaLibraryRepository();
    addTearDown(() {
      repository.close();
    });

    await _pumpApp(tester, router, repository);
    router.go('/novel/book-42');
    await _pumpRoute(tester);

    expect(find.text('小说详情'), findsOneWidget);
    expect(find.text('Book book-42'), findsOneWidget);
  });

  testWidgets('shows a safe page for an invalid media id', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final repository = FakeMediaLibraryRepository();
    addTearDown(() {
      repository.close();
    });

    await _pumpApp(tester, router, repository);
    router.go('/novel/%20');
    await _pumpRoute(tester);

    expect(find.text('无法打开该内容'), findsOneWidget);
    expect(find.text('返回媒体库'), findsOneWidget);

    await tester.tap(find.text('返回媒体库'));
    await _pumpRoute(tester);

    expect(find.text('媒体库还是空的'), findsOneWidget);
  });

  testWidgets('opens the reader with the media id', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final repository = FakeMediaLibraryRepository();
    addTearDown(() {
      repository.close();
    });

    await _pumpApp(tester, router, repository);
    router.go('/novel/book-42/read');
    await _pumpRoute(tester);

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Reader body'), findsOneWidget);
  });

  testWidgets('direct reader route always returns to the library', (
    tester,
  ) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);

    await _pumpApp(tester, router, repository);
    router.go('/novel/book-42/read');
    await _pumpRoute(tester);

    expect(find.byKey(const Key('reader-exit')), findsOneWidget);
    await tester.tap(find.byKey(const Key('reader-exit')));
    await _pumpRoute(tester);

    expect(find.text('媒体库还是空的'), findsOneWidget);
  });

  testWidgets('shows a safe page for an unknown path', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final repository = FakeMediaLibraryRepository();
    addTearDown(() {
      repository.close();
    });

    await _pumpApp(tester, router, repository);
    router.go('/unknown');
    await _pumpRoute(tester);

    expect(find.text('无法打开该内容'), findsOneWidget);
  });

  test('route helpers encode media ids as one path segment', () {
    expect(AppRoutes.novelDetails('folder/book 1'), '/novel/folder%2Fbook%201');
    expect(AppRoutes.novelReader('book?#1'), '/novel/book%3F%231/read');
  });
}

Future<void> _pumpApp(
  WidgetTester tester,
  GoRouter router,
  FakeMediaLibraryRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mediaLibraryRepositoryProvider.overrideWithValue(repository),
        novelDetailsRepositoryProvider.overrideWithValue(
          const _RouteNovelDetailsRepository(),
        ),
        novelReaderRepositoryProvider.overrideWith(
          (ref) async => const _RouteNovelReaderRepository(),
        ),
        readerPreferenceRepositoryProvider.overrideWithValue(
          const _RouteReaderPreferenceRepository(),
        ),
        readingProgressRepositoryProvider.overrideWithValue(
          const _RouteReadingProgressRepository(),
        ),
      ],
      child: MirascopeApp(router: router),
    ),
  );
  repository.activeController.add([]);
  await _pumpRoute(tester);
}

final class _RouteNovelDetailsRepository implements NovelDetailsRepository {
  const _RouteNovelDetailsRepository();

  @override
  Future<NovelDetails?> findDetails(String mediaItemId) async {
    final now = DateTime.utc(2026, 7, 29);
    return NovelDetails(
      mediaItem: MediaItem(
        id: mediaItemId,
        mediaType: MediaType.novel,
        title: 'Book $mediaItemId',
        createdAt: now,
        updatedAt: now,
      ),
      chapters: [
        ContentUnit(
          id: 'chapter-1',
          mediaItemId: mediaItemId,
          unitType: ContentUnitType.chapter,
          title: 'First',
          orderIndex: 0,
          contentRef: 'content/book.txt',
          sourceLocator: 'txt-v1:0:0:1',
          contentHash: 'hash',
        ),
      ],
      sourceAvailable: true,
    );
  }
}

final class _RouteNovelReaderRepository implements NovelReaderRepository {
  const _RouteNovelReaderRepository();

  @override
  Future<ReaderBook?> loadBook(String mediaItemId) async {
    final now = DateTime.utc(2026, 7, 29);
    return ReaderBook(
      mediaItem: MediaItem(
        id: mediaItemId,
        mediaType: MediaType.novel,
        title: 'Book',
        createdAt: now,
        updatedAt: now,
      ),
      chapters: [
        ContentUnit(
          id: 'chapter-1',
          mediaItemId: mediaItemId,
          unitType: ContentUnitType.chapter,
          title: 'First',
          orderIndex: 0,
          contentRef: 'content/book.txt',
          sourceLocator: 'txt-v1:0:0:1',
          contentHash: 'hash',
        ),
      ],
    );
  }

  @override
  Future<ReaderChapter> readChapter(ContentUnit unit) async {
    return ReaderChapter(unit: unit, text: 'Reader body');
  }
}

final class _RouteReaderPreferenceRepository
    implements ReaderPreferenceRepository {
  const _RouteReaderPreferenceRepository();

  @override
  Future<EffectiveReaderPreference> resolveForMedia(String mediaItemId) async {
    return const EffectiveReaderPreference(
      fontSize: 18,
      lineHeight: 1.6,
      themeKey: 'system',
      readingMode: ReadingMode.vertical,
    );
  }

  @override
  Future<EffectiveReaderPreference> resolveGlobal() =>
      resolveForMedia('global');

  @override
  Future<void> save(ReaderPreference preference) async {}

  @override
  Future<ReaderPreference?> findForMedia(String mediaItemId) async => null;

  @override
  Future<ReaderPreference?> findGlobal() async => null;
}

final class _RouteReadingProgressRepository
    implements ReadingProgressRepository {
  const _RouteReadingProgressRepository();

  @override
  Future<ReadingProgress?> findForMedia(String mediaItemId) async => null;

  @override
  Future<ProgressWriteResult> save(ReadingProgress progress) async =>
      ProgressWriteResult.inserted;
}

Future<void> _pumpRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}
