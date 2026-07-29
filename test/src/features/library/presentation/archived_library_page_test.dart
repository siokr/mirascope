import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/library/domain/library_entry.dart';
import 'package:mirascope/src/features/library/domain/library_item.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/library/presentation/archived_library_page.dart';
import 'package:mirascope/src/features/library/presentation/widgets/library_loading_grid.dart';

import '../library_test_support.dart';

void main() {
  testWidgets('shows loading then the archived empty state', (tester) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);

    await _pumpPage(tester, repository);
    expect(find.byType(LibraryLoadingGrid), findsOneWidget);

    repository.archivedController.add([]);
    await tester.pump();

    expect(find.text('没有已归档内容'), findsOneWidget);
    expect(find.textContaining('不会删除原文件'), findsOneWidget);
  });

  testWidgets('shows a safe error and retry resubscribes', (tester) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);

    await _pumpPage(tester, repository);
    repository.archivedController.addError(
      StateError('C:/private/archive.sqlite'),
    );
    await tester.pump();

    expect(find.text('暂时无法读取媒体库'), findsOneWidget);
    expect(find.textContaining('C:/private'), findsNothing);
    await tester.tap(find.text('重试'));
    await tester.pump();
    expect(repository.archivedWatchCount, 2);
  });

  testWidgets('restores an archived item without a delete action', (
    tester,
  ) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);

    await _pumpPage(tester, repository);
    repository.archivedController.add([_item('book-1')]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('library-menu-book-1')));
    await tester.pumpAndSettle();
    expect(find.text('永久删除'), findsNothing);
    expect(find.text('恢复到媒体库'), findsOneWidget);
    await tester.tap(find.text('恢复到媒体库'));
    await tester.pumpAndSettle();

    expect(repository.restored, ['book-1']);
    expect(find.text('已恢复到媒体库'), findsOneWidget);
  });

  testWidgets('restore failure shows stable feedback', (tester) async {
    final repository = FakeMediaLibraryRepository()
      ..restoreError = StateError('private restore failure');
    addTearDown(repository.close);

    await _pumpPage(tester, repository);
    repository.archivedController.add([_item('book-1')]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('library-menu-book-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('恢复到媒体库'));
    await tester.pumpAndSettle();

    expect(find.text('无法恢复，请重试。'), findsOneWidget);
    expect(find.textContaining('private'), findsNothing);
  });

  testWidgets('narrow archived grid does not overflow', (tester) async {
    tester.view.physicalSize = const Size(600, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);

    await _pumpPage(tester, repository);
    repository.archivedController.add([
      _item('book-1', title: '一本标题非常非常长但仍然需要在窄窗口正确显示的小说'),
    ]);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('已归档'), findsOneWidget);
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  FakeMediaLibraryRepository repository,
) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [mediaLibraryRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: ArchivedLibraryPage()),
    ),
  );
}

LibraryItem _item(String id, {String title = '长夜书简'}) {
  final now = DateTime.utc(2026, 7, 29);
  return LibraryItem(
    mediaItem: MediaItem(
      id: id,
      mediaType: MediaType.novel,
      title: title,
      creator: '林遥',
      createdAt: now,
      updatedAt: now,
    ),
    libraryEntry: LibraryEntry(
      id: 'entry-$id',
      mediaItemId: id,
      favorite: false,
      addedAt: now,
      archivedAt: now,
    ),
  );
}
