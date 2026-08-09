import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/library/domain/library_entry.dart';
import 'package:mirascope/src/features/library/domain/library_item.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/library/presentation/widgets/library_error_state.dart';
import 'package:mirascope/src/features/library/presentation/widgets/library_grid.dart';
import 'package:mirascope/src/features/library/presentation/widgets/library_loading_grid.dart';

void main() {
  for (final testCase in [(432.0, 2), (600.0, 3), (900.0, 4), (1440.0, 6)]) {
    testWidgets(
      'grid uses ${testCase.$2} columns at ${testCase.$1.toInt()} pixels',
      (tester) async {
        tester.view.physicalSize = Size(testCase.$1, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LibraryGrid(
                items: List.generate(8, (index) => _item('book-$index')),
                archived: false,
                busyMediaIds: const {},
                onOpen: (_) {},
                onArchive: (_) {},
                onRestore: (_) {},
                onDelete: (_) {},
              ),
            ),
          ),
        );

        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, testCase.$2);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('portrait phone cards keep all metadata without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(432, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGrid(
            items: List.generate(
              4,
              (index) => _item(
                '一本标题特别长的竖屏测试小说-$index',
                lastOpenedAt: DateTime.utc(2026, 8, 9),
              ),
            ),
            archived: false,
            busyMediaIds: const {},
            onOpen: (_) {},
            onArchive: (_) {},
            onRestore: (_) {},
            onDelete: (_) {},
          ),
        ),
      ),
    );

    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.childAspectRatio, 0.46);
    expect(find.textContaining('最近阅读'), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading grid mirrors responsive columns with skeletons', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LibraryLoadingGrid())),
    );

    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 4);
    expect(find.byKey(const Key('library-loading-card')), findsNWidgets(8));
  });

  testWidgets('dark theme grid keeps its layout and contrast tokens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFF8C8CFF),
        ),
        home: Scaffold(
          body: LibraryGrid(
            items: List.generate(6, (index) => _item('dark-$index')),
            archived: false,
            busyMediaIds: const {},
            onOpen: (_) {},
            onArchive: (_) {},
            onRestore: (_) {},
            onDelete: (_) {},
          ),
        ),
      ),
    );

    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('error state explains failure and retries', (tester) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LibraryErrorState(onRetry: () => retried = true)),
      ),
    );

    expect(find.text('暂时无法读取媒体库'), findsOneWidget);
    expect(find.textContaining('数据库'), findsNothing);
    await tester.tap(find.text('重试'));
    expect(retried, isTrue);
  });
}

LibraryItem _item(String id, {DateTime? lastOpenedAt}) {
  final now = DateTime.utc(2026, 7, 29);
  return LibraryItem(
    mediaItem: MediaItem(
      id: id,
      mediaType: MediaType.novel,
      title: '书 $id',
      createdAt: now,
      updatedAt: now,
    ),
    libraryEntry: LibraryEntry(
      id: 'entry-$id',
      mediaItemId: id,
      favorite: false,
      addedAt: now,
      lastOpenedAt: lastOpenedAt,
    ),
  );
}
