import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/core/errors/app_error_code.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/application/import_txt.dart';
import 'package:mirascope/src/features/importing/application/import_epub.dart';
import 'package:mirascope/src/features/importing/application/prepare_epub_source.dart';
import 'package:mirascope/src/features/importing/application/prepare_txt_source.dart';
import 'package:mirascope/src/features/importing/application/import_manga.dart';
import 'package:mirascope/src/features/importing/application/prepare_manga_source.dart';
import 'package:mirascope/src/features/importing/domain/decoded_txt.dart';
import 'package:mirascope/src/features/importing/domain/epub_source_candidate.dart';
import 'package:mirascope/src/features/importing/domain/txt_encoding.dart';
import 'package:mirascope/src/features/importing/domain/txt_source_candidate.dart';
import 'package:mirascope/src/features/importing/domain/manga_source.dart';
import 'package:mirascope/src/features/library/domain/library_entry.dart';
import 'package:mirascope/src/features/library/domain/custom_shelf.dart';
import 'package:mirascope/src/features/library/domain/library_organization_repository.dart';
import 'package:mirascope/src/features/library/domain/media_tag.dart';
import 'package:mirascope/src/features/library/domain/library_item.dart';
import 'package:mirascope/src/features/library/domain/library_query.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/library/presentation/library_page.dart';
import 'package:mirascope/src/features/library/presentation/widgets/library_loading_grid.dart';

import '../library_test_support.dart';

void main() {
  testWidgets('organizes a book with tags and custom shelves', (tester) async {
    final repository = FakeMediaLibraryRepository();
    final organization = _FakeOrganizationRepository();
    addTearDown(repository.close);
    await _pumpPage(tester, repository, organization: organization);
    repository.activeController.add([_item('book-1', '长夜书简')]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('library-menu-book-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('标签与书架'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('organization-sheet')), findsOneWidget);
    await tester.tap(find.byKey(const Key('organization-tag')));
    await tester.pump();
    expect(organization.assignedTagIds, {'tag'});
    await tester.tap(find.byKey(const Key('organization-shelf')));
    await tester.pump();
    expect(organization.assignedShelfIds, {'shelf'});

    await tester.tap(find.text('新建标签'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('organization-name-field')),
      '奇幻',
    );
    await tester.tap(find.text('创建'));
    await tester.pumpAndSettle();
    expect(organization.createdTags.single.name, '奇幻');
  });

  testWidgets('toggles favorite from the book menu', (tester) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    await _pumpPage(tester, repository);
    repository.activeController.add([_item('book-1', '长夜书简')]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('library-menu-book-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加收藏'));
    await tester.pump();

    expect(repository.favoriteValues, {'book-1': true});
  });

  testWidgets('centrally renames tags and confirms shelf deletion', (
    tester,
  ) async {
    final repository = FakeMediaLibraryRepository();
    final organization = _FakeOrganizationRepository();
    addTearDown(repository.close);
    await _pumpPage(tester, repository, organization: organization);
    repository.activeController.add([_item('book-1', '长夜书简')]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('open-organization-management')));
    await tester.pumpAndSettle();
    expect(find.text('标签与书架管理'), findsOneWidget);
    expect(find.text('收藏'), findsOneWidget);
    expect(find.text('待读'), findsOneWidget);

    await tester.tap(find.byKey(const Key('manage-tag-tag')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('重命名'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('organization-name-field')),
      '喜爱',
    );
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(organization.renamedTags, {'tag': '喜爱'});

    await tester.tap(find.byKey(const Key('manage-shelf-shelf')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除书架“待读”？'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();
    expect(organization.deletedShelfIds, ['shelf']);
  });

  testWidgets('shows loading then the active empty state', (tester) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);

    await _pumpPage(tester, repository);
    expect(find.byType(LibraryLoadingGrid), findsOneWidget);

    repository.activeController.add([]);
    await tester.pump();

    expect(find.text('媒体库还是空的'), findsOneWidget);
    expect(find.text('导入 TXT 或 EPUB 小说后，它会出现在这里。'), findsOneWidget);
    expect(find.text('导入 TXT'), findsOneWidget);
    expect(find.text('导入 EPUB'), findsOneWidget);
  });

  testWidgets('searches through the repository and can close search', (
    tester,
  ) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    await _pumpPage(tester, repository);
    repository.activeController.add([_item('book-1', '长夜书简')]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('open-library-search')));
    await tester.pump();
    expect(find.byKey(const Key('library-search-field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('library-search-field')),
      '  林遥  ',
    );
    await tester.pump();
    expect(repository.lastQuery?.searchText, '  林遥  ');

    repository.activeController.add([_item('book-1', '长夜书简')]);
    await tester.pump();
    expect(find.text('长夜书简'), findsOneWidget);

    await tester.tap(find.byKey(const Key('close-library-search')));
    await tester.pump();
    expect(find.byKey(const Key('library-search-field')), findsNothing);
    expect(repository.lastQuery?.searchText, isEmpty);
  });

  testWidgets('search empty state clears the current query', (tester) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    await _pumpPage(tester, repository);
    repository.activeController.add([]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('open-library-search')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('library-search-field')),
      '不存在',
    );
    await tester.pump();
    repository.activeController.add([]);
    await tester.pump();

    expect(find.text('没有找到匹配内容'), findsOneWidget);
    expect(find.text('试试其他书名或作者关键词。'), findsOneWidget);
    await tester.tap(find.byKey(const Key('clear-library-search')));
    await tester.pump();
    expect(repository.lastQuery?.searchText, isEmpty);
  });

  testWidgets('applies media favorite and sort filters together', (
    tester,
  ) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    await _pumpPage(tester, repository);
    repository.activeController.add([_item('book-1', '长夜书简')]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('open-library-filters')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('filter-media-manga')));
    await tester.tap(find.byKey(const Key('filter-favorite-only')));
    await tester.ensureVisible(find.byKey(const Key('sort-titleAscending')));
    await tester.tap(find.byKey(const Key('sort-titleAscending')));
    await tester.ensureVisible(find.byKey(const Key('apply-library-filters')));
    await tester.tap(find.byKey(const Key('apply-library-filters')));
    await tester.pumpAndSettle();

    expect(repository.lastQuery?.mediaTypes, {MediaType.manga});
    expect(repository.lastQuery?.favoriteOnly, isTrue);
    expect(repository.lastQuery?.sort, LibrarySort.titleAscending);
    expect(find.byTooltip('筛选和排序，已应用'), findsOneWidget);
  });

  testWidgets('cancelling filters preserves the current query', (tester) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    await _pumpPage(tester, repository);
    repository.activeController.add([]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('open-library-filters')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('filter-media-manga')));
    await tester.ensureVisible(find.byKey(const Key('cancel-library-filters')));
    await tester.tap(find.byKey(const Key('cancel-library-filters')));
    await tester.pumpAndSettle();

    expect(repository.lastQuery?.mediaTypes, isEmpty);
    expect(repository.activeWatchCount, 1);
  });

  testWidgets('filtered empty state can reset applied filters', (tester) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    await _pumpPage(tester, repository);
    repository.activeController.add([]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('open-library-filters')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('filter-media-novel')));
    await tester.ensureVisible(find.byKey(const Key('apply-library-filters')));
    await tester.tap(find.byKey(const Key('apply-library-filters')));
    await tester.pumpAndSettle();
    repository.activeController.add([]);
    await tester.pumpAndSettle();

    expect(find.text('试试减少筛选条件。'), findsOneWidget);
    expect(find.text('重置筛选'), findsOneWidget);
    await tester.tap(find.text('重置筛选'));
    await tester.pump();
    expect(repository.lastQuery?.mediaTypes, isEmpty);
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

  testWidgets('CBZ manga imports and opens its manga details', (tester) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    String? openedId;
    await _pumpPage(
      tester,
      repository,
      onOpenManga: (id) => openedId = id,
      prepareMangaForImport: (kind) async {
        expect(kind, MangaSourceKind.archive);
        return MangaSourceReady(_mangaCandidate);
      },
      completeMangaImport: (_) async => const MangaImportSucceeded('manga-1'),
    );
    repository.activeController.add([]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('import-manga')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('import-manga-archive')));
    await tester.pumpAndSettle();

    expect(openedId, 'manga-1');
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

  testWidgets('EPUB source imports metadata and opens the new novel', (
    tester,
  ) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    String? openedId;
    EpubSourceCandidate? importedCandidate;
    await _pumpPage(
      tester,
      repository,
      onOpenNovel: (id) => openedId = id,
      prepareEpubForImport: () async => EpubSourceReady(_epubCandidate),
      completeEpubImport: (candidate) async {
        importedCandidate = candidate;
        return const EpubImportSucceeded('epub-book');
      },
    );
    repository.activeController.add([]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('import-epub')));
    await tester.pumpAndSettle();

    expect(importedCandidate, same(_epubCandidate));
    expect(openedId, 'epub-book');
  });

  testWidgets('EPUB DRM failure shows message and recovery without details', (
    tester,
  ) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    await _pumpPage(
      tester,
      repository,
      prepareEpubForImport: () async => EpubSourceReady(_epubCandidate),
      completeEpubImport: (_) async => EpubImportFailed(
        AppFailure.fromCode(AppErrorCode.epubDrmUnsupported),
      ),
    );
    repository.activeController.add([]);
    await tester.pump();

    await tester.tap(find.byKey(const Key('import-epub')));
    await tester.pumpAndSettle();

    expect(find.text(AppErrorCode.epubDrmUnsupported.message), findsOneWidget);
    expect(find.text(AppErrorCode.epubDrmUnsupported.recovery), findsOneWidget);
    expect(find.textContaining('private-source'), findsNothing);
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
  ValueChanged<String>? onOpenManga,
  PrepareTxtForImport? prepareTxtForImport,
  CompleteTxtImport? completeTxtImport,
  PrepareEpubForImport? prepareEpubForImport,
  CompleteEpubImport? completeEpubImport,
  PrepareMangaForImport? prepareMangaForImport,
  CompleteMangaImport? completeMangaImport,
  LibraryOrganizationRepository? organization,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        mediaLibraryRepositoryProvider.overrideWithValue(repository),
        if (organization != null)
          libraryOrganizationRepositoryProvider.overrideWithValue(organization),
      ],
      child: MaterialApp(
        home: LibraryPage(
          onOpenSettings: () {},
          onOpenArchive: () {},
          onOpenNovel: onOpenNovel ?? (_) {},
          onOpenManga: onOpenManga,
          prepareTxtForImport: prepareTxtForImport,
          completeTxtImport: completeTxtImport,
          prepareEpubForImport: prepareEpubForImport,
          completeEpubImport: completeEpubImport,
          prepareMangaForImport: prepareMangaForImport,
          completeMangaImport: completeMangaImport,
        ),
      ),
    ),
  );
}

final class _FakeOrganizationRepository
    implements LibraryOrganizationRepository {
  final assignedTagIds = <String>{};
  final assignedShelfIds = <String>{};
  final createdTags = <MediaTag>[];
  final renamedTags = <String, String>{};
  final deletedShelfIds = <String>[];

  @override
  Stream<List<MediaTag>> watchTags() => Stream.value([
    MediaTag(id: 'tag', name: '收藏', createdAt: DateTime.utc(2026)),
  ]);

  @override
  Stream<List<CustomShelf>> watchShelves() => Stream.value([
    CustomShelf(
      id: 'shelf',
      name: '待读',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  ]);

  @override
  Stream<Set<String>> watchTagIdsForMedia(String mediaItemId) =>
      Stream.value(assignedTagIds);

  @override
  Stream<Set<String>> watchShelfIdsForMedia(String mediaItemId) =>
      Stream.value(assignedShelfIds);

  @override
  Future<void> createTag(MediaTag tag) async => createdTags.add(tag);

  @override
  Future<void> createShelf(CustomShelf shelf) async {}

  @override
  Future<void> setTagAssigned({
    required String tagId,
    required String mediaItemId,
    required bool assigned,
    required DateTime changedAt,
  }) async =>
      assigned ? assignedTagIds.add(tagId) : assignedTagIds.remove(tagId);

  @override
  Future<void> setMediaInShelf({
    required String shelfId,
    required String mediaItemId,
    required bool included,
    required DateTime changedAt,
  }) async => included
      ? assignedShelfIds.add(shelfId)
      : assignedShelfIds.remove(shelfId);

  @override
  Future<void> deleteShelf(String shelfId) async =>
      deletedShelfIds.add(shelfId);
  @override
  Future<void> deleteTag(String tagId) async {}
  @override
  Future<void> renameShelf(
    String shelfId,
    String name,
    DateTime updatedAt,
  ) async {}
  @override
  Future<void> renameTag(String tagId, String name) async =>
      renamedTags[tagId] = name;
}

final _candidate = TxtSourceCandidate(
  path: 'private-source',
  fileSize: 1024,
  modifiedAt: DateTime.utc(2026, 7, 29),
  fingerprint: 'sha256:safe:1024',
);

final _epubCandidate = EpubSourceCandidate(
  path: 'private-source.epub',
  fileSize: 2048,
  modifiedAt: DateTime.utc(2026, 8, 7),
  fingerprint: 'sha256:epub:2048',
);

final _mangaCandidate = MangaSourceCandidate(
  path: 'private-source.cbz',
  kind: MangaSourceKind.archive,
  fileSize: 4096,
  modifiedAt: DateTime.utc(2026, 8, 15),
  fingerprint: 'sha256:manga:4096',
  imageCount: 2,
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
