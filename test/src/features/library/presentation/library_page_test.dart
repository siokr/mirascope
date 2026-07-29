import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/library/domain/library_entry.dart';
import 'package:mirascope/src/features/library/domain/library_item.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/library/presentation/library_page.dart';
import 'package:mirascope/src/features/library/presentation/widgets/library_loading_grid.dart';

import '../library_test_support.dart';

void main() {
  testWidgets('shows loading then the active empty state', (tester) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);

    await _pumpPage(tester, repository);
    expect(find.byType(LibraryLoadingGrid), findsOneWidget);

    repository.activeController.add([]);
    await tester.pump();

    expect(find.text('媒体库还是空的'), findsOneWidget);
    expect(find.text('导入 TXT 小说后，它会出现在这里。'), findsOneWidget);
    expect(find.text('导入'), findsNothing);
  });

  testWidgets('shows stream error safely and retry resubscribes', (
    tester,
  ) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);

    await _pumpPage(tester, repository);
    repository.activeController.addError(
      StateError('C:/private/books/database.sqlite'),
    );
    await tester.pump();

    expect(find.text('暂时无法读取媒体库'), findsOneWidget);
    expect(find.textContaining('C:/private'), findsNothing);
    await tester.tap(find.text('重试'));
    await tester.pump();
    expect(repository.activeWatchCount, 2);
  });

  testWidgets('opens a novel only after recording its time', (tester) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    String? openedId;

    await _pumpPage(
      tester,
      repository,
      onOpenNovel: (id) {
        expect(repository.openedAt, contains(id));
        openedId = id;
      },
    );
    repository.activeController.add([_item('book-1', '长夜书简')]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('library-card-book-1')));
    await tester.pumpAndSettle();

    expect(openedId, 'book-1');
  });

  testWidgets('open failure stays on page and shows a safe message', (
    tester,
  ) async {
    final repository = FakeMediaLibraryRepository()
      ..markOpenedError = StateError('private database failure');
    addTearDown(repository.close);
    var navigated = false;

    await _pumpPage(tester, repository, onOpenNovel: (_) => navigated = true);
    repository.activeController.add([_item('book-1', '长夜书简')]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('library-card-book-1')));
    await tester.pumpAndSettle();

    expect(navigated, isFalse);
    expect(find.text('无法打开这本书，请重试。'), findsOneWidget);
    expect(find.textContaining('private'), findsNothing);
  });

  testWidgets('archive confirmation explains file safety and can cancel', (
    tester,
  ) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);

    await _pumpPage(tester, repository);
    repository.activeController.add([_item('book-1', '长夜书简')]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('library-menu-book-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('移入归档'));
    await tester.pumpAndSettle();

    expect(find.text('归档《长夜书简》？'), findsOneWidget);
    expect(find.textContaining('不会删除原文件'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(repository.archivedAt, isEmpty);
  });

  testWidgets('archive succeeds and snackbar can undo it', (tester) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);

    await _pumpPage(tester, repository);
    repository.activeController.add([_item('book-1', '长夜书简')]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('library-menu-book-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('移入归档'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '移入归档'));
    await tester.pumpAndSettle();

    expect(repository.archivedAt, contains('book-1'));
    expect(find.text('已移入归档'), findsOneWidget);
    await tester.tap(find.text('撤销'));
    await tester.pumpAndSettle();
    expect(repository.restored, ['book-1']);
  });

  testWidgets('archive failure shows stable feedback', (tester) async {
    final repository = FakeMediaLibraryRepository()
      ..archiveError = StateError('private archive failure');
    addTearDown(repository.close);

    await _pumpPage(tester, repository);
    repository.activeController.add([_item('book-1', '长夜书简')]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('library-menu-book-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('移入归档'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '移入归档'));
    await tester.pumpAndSettle();

    expect(find.text('无法归档，请重试。'), findsOneWidget);
    expect(find.textContaining('private'), findsNothing);
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  FakeMediaLibraryRepository repository, {
  ValueChanged<String>? onOpenNovel,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [mediaLibraryRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        home: LibraryPage(
          onOpenSettings: () {},
          onOpenArchive: () {},
          onOpenNovel: onOpenNovel ?? (_) {},
        ),
      ),
    ),
  );
}

LibraryItem _item(String id, String title) {
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
    ),
  );
}
