import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/core/errors/app_error_code.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/application/import_txt.dart';
import 'package:mirascope/src/features/importing/application/prepare_txt_source.dart';
import 'package:mirascope/src/features/importing/domain/decoded_txt.dart';
import 'package:mirascope/src/features/importing/domain/txt_encoding.dart';
import 'package:mirascope/src/features/importing/domain/txt_source_candidate.dart';
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
    expect(find.text('导入 TXT'), findsOneWidget);
  });

  testWidgets('cancelled import stays on the library without feedback', (
    tester,
  ) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    var opened = false;
    await _pumpPage(
      tester,
      repository,
      onOpenNovel: (_) => opened = true,
      prepareTxtForImport: () async => const TxtSourceCancelled(),
    );
    repository.activeController.add([]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('import-txt')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(opened, isFalse);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('导入 TXT'), findsOneWidget);
  });

  testWidgets('duplicate import opens the existing novel', (tester) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    String? openedId;
    await _pumpPage(
      tester,
      repository,
      onOpenNovel: (id) => openedId = id,
      prepareTxtForImport: () async => TxtSourceDuplicate(
        candidate: _candidate,
        mediaItemId: 'existing-book',
      ),
    );
    repository.activeController.add([]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('import-txt')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(openedId, 'existing-book');
  });

  testWidgets('new source confirms title and opens successful import', (
    tester,
  ) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    String? importedTitle;
    String? openedId;
    await _pumpPage(
      tester,
      repository,
      onOpenNovel: (id) => openedId = id,
      prepareTxtForImport: () async => TxtSourceReady(_candidate),
      completeTxtImport:
          ({required candidate, required title, selectedEncoding}) async {
            importedTitle = title;
            expect(selectedEncoding, isNull);
            return const TxtImportSucceeded('new-book');
          },
    );
    repository.activeController.add([]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('import-txt')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byKey(const Key('import-title')), '  长夜书简  ');
    await tester.tap(find.byKey(const Key('confirm-import-title')));
    await tester.pumpAndSettle();

    expect(importedTitle, '长夜书简');
    expect(openedId, 'new-book');
  });

  testWidgets('unknown encoding retries with the explicit user choice', (
    tester,
  ) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    final encodings = <TxtEncoding?>[];
    await _pumpPage(
      tester,
      repository,
      prepareTxtForImport: () async => TxtSourceReady(_candidate),
      completeTxtImport:
          ({required candidate, required title, selectedEncoding}) async {
            encodings.add(selectedEncoding);
            if (selectedEncoding == null) {
              return TxtImportEncodingChoiceRequired(
                TxtEncodingChoiceRequired(
                  AppFailure.fromCode(AppErrorCode.encodingUnknown),
                ),
              );
            }
            return const TxtImportSucceeded('encoded-book');
          },
    );
    repository.activeController.add([]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('import-txt')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byKey(const Key('import-title')), '编码测试');
    await tester.tap(find.byKey(const Key('confirm-import-title')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('encoding-gb18030')));
    await tester.pumpAndSettle();

    expect(encodings, [null, TxtEncoding.gb18030]);
  });

  testWidgets('import failure shows only the safe message', (tester) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    await _pumpPage(
      tester,
      repository,
      prepareTxtForImport: () async => TxtSourceFailed(
        AppFailure.fromCode(AppErrorCode.filePermissionDenied),
      ),
    );
    repository.activeController.add([]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('import-txt')));
    await tester.pumpAndSettle();

    expect(
      find.text(AppErrorCode.filePermissionDenied.message),
      findsOneWidget,
    );
    expect(find.textContaining('C:/'), findsNothing);
  });

  testWidgets('import button blocks duplicate clicks while work is active', (
    tester,
  ) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    final preparation = Completer<TxtSourcePreparationResult>();
    var calls = 0;
    await _pumpPage(
      tester,
      repository,
      prepareTxtForImport: () {
        calls++;
        return preparation.future;
      },
    );
    repository.activeController.add([]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('import-txt')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('import-txt')), warnIfMissed: false);
    expect(calls, 1);
    expect(find.text('正在导入'), findsOneWidget);

    preparation.complete(const TxtSourceCancelled());
    await tester.pumpAndSettle();
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
  PrepareTxtForImport? prepareTxtForImport,
  CompleteTxtImport? completeTxtImport,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [mediaLibraryRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        home: LibraryPage(
          onOpenSettings: () {},
          onOpenArchive: () {},
          onOpenNovel: onOpenNovel ?? (_) {},
          prepareTxtForImport: prepareTxtForImport,
          completeTxtImport: completeTxtImport,
        ),
      ),
    ),
  );
}

final _candidate = TxtSourceCandidate(
  path: 'private-source',
  fileSize: 1024,
  modifiedAt: DateTime.utc(2026, 7, 29),
  fingerprint: 'sha256:safe:1024',
);

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
