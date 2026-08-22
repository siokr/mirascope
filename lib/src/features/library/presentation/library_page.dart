import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirascope/src/shared/widgets/empty_state.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/app_error_code.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/ids/id_generator.dart';
import '../../importing/application/import_txt.dart';
import '../../importing/application/import_epub.dart';
import '../../importing/application/importing_providers.dart';
import '../../importing/application/import_manga.dart';
import '../../importing/application/prepare_manga_source.dart';
import '../../importing/application/prepare_epub_source.dart';
import '../../importing/application/prepare_txt_source.dart';
import '../../importing/domain/epub_source_candidate.dart';
import '../../importing/domain/txt_encoding.dart';
import '../../importing/domain/txt_source_candidate.dart';
import '../../importing/domain/manga_source.dart';
import '../application/library_actions_controller.dart';
import '../application/library_providers.dart';
import '../domain/library_item.dart';
import '../domain/library_query.dart';
import '../domain/custom_shelf.dart';
import '../domain/media_tag.dart';
import '../domain/media_item.dart';
import 'widgets/library_error_state.dart';
import 'widgets/library_grid.dart';
import 'widgets/library_loading_grid.dart';

typedef PrepareTxtForImport = Future<TxtSourcePreparationResult> Function();
typedef PrepareEpubForImport = Future<EpubSourcePreparationResult> Function();
typedef CompleteEpubImport =
    Future<EpubImportResult> Function(EpubSourceCandidate candidate);
typedef PrepareMangaForImport =
    Future<MangaSourcePreparationResult> Function(MangaSourceKind kind);
typedef CompleteMangaImport =
    Future<MangaImportResult> Function(MangaSourceCandidate candidate);
typedef CompleteTxtImport =
    Future<TxtImportResult> Function({
      required TxtSourceCandidate candidate,
      required String title,
      TxtEncoding? selectedEncoding,
    });

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({
    required this.onOpenSettings,
    required this.onOpenArchive,
    required this.onOpenNovel,
    this.onOpenManga,
    this.prepareTxtForImport,
    this.completeTxtImport,
    this.prepareEpubForImport,
    this.completeEpubImport,
    this.prepareMangaForImport,
    this.completeMangaImport,
    super.key,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onOpenArchive;
  final ValueChanged<String> onOpenNovel;
  final ValueChanged<String>? onOpenManga;
  final PrepareTxtForImport? prepareTxtForImport;
  final CompleteTxtImport? completeTxtImport;
  final PrepareEpubForImport? prepareEpubForImport;
  final CompleteEpubImport? completeEpubImport;
  final PrepareMangaForImport? prepareMangaForImport;
  final CompleteMangaImport? completeMangaImport;

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  var _importing = false;
  var _searching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(activeLibraryProvider);
    final query = ref.watch(libraryQueryProvider);
    final busyMediaIds = ref.watch(libraryActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                key: const Key('library-search-field'),
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: '搜索书名、作者',
                  border: InputBorder.none,
                ),
                onChanged: ref
                    .read(libraryQueryProvider.notifier)
                    .setSearchText,
              )
            : const Text('媒体库'),
        actions: [
          IconButton(
            key: Key(
              _searching ? 'close-library-search' : 'open-library-search',
            ),
            onPressed: _toggleSearch,
            tooltip: _searching ? '关闭搜索' : '搜索',
            icon: Icon(_searching ? Icons.close : Icons.search),
          ),
          IconButton(
            key: const Key('open-library-filters'),
            onPressed: _openFilters,
            tooltip: query.hasActiveFilters ? '筛选和排序，已应用' : '筛选和排序',
            icon: Icon(
              query.hasActiveFilters
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
            ),
          ),
          IconButton(
            key: const Key('open-archive'),
            onPressed: widget.onOpenArchive,
            tooltip: '已归档',
            icon: const Icon(Icons.inventory_2_outlined),
          ),
          IconButton(
            key: const Key('open-organization-management'),
            onPressed: _openOrganizationManagement,
            tooltip: '标签与书架管理',
            icon: const Icon(Icons.label_outline),
          ),
          IconButton(
            key: const Key('open-settings'),
            onPressed: widget.onOpenSettings,
            tooltip: '设置',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: library.when(
        loading: () => const LibraryLoadingGrid(),
        error: (_, _) => LibraryErrorState(
          onRetry: () => ref.invalidate(activeLibraryProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            if (query.normalizedSearchText.isNotEmpty ||
                query.hasActiveFilters) {
              final searching = query.normalizedSearchText.isNotEmpty;
              return EmptyState(
                icon: Icons.search_off_outlined,
                title: '没有找到匹配内容',
                message: searching ? '试试其他书名或作者关键词。' : '试试减少筛选条件。',
                action: TextButton(
                  key: const Key('clear-library-search'),
                  onPressed: searching ? _clearSearch : _resetFilters,
                  child: Text(searching ? '清除搜索' : '重置筛选'),
                ),
              );
            }
            return const EmptyState(
              icon: Icons.menu_book_outlined,
              title: '媒体库还是空的',
              message: '导入 TXT 或 EPUB 小说后，它会出现在这里。',
            );
          }
          return LibraryGrid(
            items: items,
            archived: false,
            busyMediaIds: busyMediaIds,
            onOpen: (item) => unawaited(_open(context, ref, item)),
            onArchive: (item) => unawaited(_confirmArchive(context, ref, item)),
            onRestore: (_) {},
            onDelete: (_) {},
            onOrganize: (item) => unawaited(_openOrganization(item)),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            key: const Key('import-manga'),
            heroTag: 'import-manga',
            onPressed: _importing ? null : _chooseMangaSource,
            icon: const Icon(Icons.collections_bookmark_outlined),
            label: const Text('导入漫画'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            key: const Key('import-epub'),
            heroTag: 'import-epub',
            onPressed: _importing ? null : _importEpub,
            icon: const Icon(Icons.book_outlined),
            label: const Text('导入 EPUB'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            key: const Key('import-txt'),
            heroTag: 'import-txt',
            onPressed: _importing ? null : _importTxt,
            icon: _importing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            label: Text(_importing ? '正在导入' : '导入 TXT'),
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    if (_searching) {
      _clearSearch();
      setState(() => _searching = false);
      return;
    }
    setState(() => _searching = true);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(libraryQueryProvider.notifier).clearSearch();
  }

  void _resetFilters() {
    ref.read(libraryQueryProvider.notifier).resetFilters();
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<LibraryQuery>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _LibraryFilterSheet(initialQuery: ref.read(libraryQueryProvider)),
    );
    if (result != null && mounted) {
      ref.read(libraryQueryProvider.notifier).applyFilters(result);
    }
  }

  Future<void> _importTxt() async {
    setState(() => _importing = true);
    try {
      final preparation =
          await widget.prepareTxtForImport?.call() ??
          await ref.read(prepareTxtSourceProvider)();
      if (!mounted) return;

      switch (preparation) {
        case TxtSourceCancelled():
          return;
        case TxtSourceDuplicate(:final mediaItemId):
          widget.onOpenNovel(mediaItemId);
          return;
        case TxtSourceFailed(:final failure):
          _showFailure(context, failure);
          return;
        case TxtSourceReady(:final candidate):
          final title = await _requestTitle();
          if (title == null || !mounted) return;
          await _completeImport(candidate, title);
          return;
      }
    } on Object {
      if (mounted) {
        _showFailure(context, AppFailure.fromCode(AppErrorCode.storageFailed));
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _completeImport(
    TxtSourceCandidate candidate,
    String title, {
    TxtEncoding? selectedEncoding,
  }) async {
    final importer = widget.completeTxtImport;
    final result = importer != null
        ? await importer(
            candidate: candidate,
            title: title,
            selectedEncoding: selectedEncoding,
          )
        : await (await ref.read(importTxtProvider.future))(
            candidate: candidate,
            title: title,
            selectedEncoding: selectedEncoding,
          );
    if (!mounted) return;

    switch (result) {
      case TxtImportSucceeded(:final mediaItemId):
        ref.invalidate(activeLibraryProvider);
        widget.onOpenNovel(mediaItemId);
        return;
      case TxtImportDuplicate(:final mediaItemId):
        widget.onOpenNovel(mediaItemId);
        return;
      case TxtImportEncodingChoiceRequired(:final choice):
        final encoding = await _requestEncoding(choice.supportedEncodings);
        if (encoding != null && mounted) {
          await _completeImport(candidate, title, selectedEncoding: encoding);
        }
        return;
      case TxtImportFailed(:final failure):
        _showFailure(context, failure);
        return;
    }
  }

  Future<void> _importEpub() async {
    setState(() => _importing = true);
    try {
      final preparation =
          await widget.prepareEpubForImport?.call() ??
          await ref.read(prepareEpubSourceProvider)();
      if (!mounted) return;

      switch (preparation) {
        case EpubSourceCancelled():
          return;
        case EpubSourceDuplicate(:final mediaItemId):
          widget.onOpenNovel(mediaItemId);
          return;
        case EpubSourceFailed(:final failure):
          _showFailure(context, failure);
          return;
        case EpubSourceReady(:final candidate):
          final importer = widget.completeEpubImport;
          final result = importer != null
              ? await importer(candidate)
              : await (await ref.read(importEpubProvider.future))(candidate);
          if (!mounted) return;
          switch (result) {
            case EpubImportSucceeded(:final mediaItemId):
              ref.invalidate(activeLibraryProvider);
              widget.onOpenNovel(mediaItemId);
              return;
            case EpubImportDuplicate(:final mediaItemId):
              widget.onOpenNovel(mediaItemId);
              return;
            case EpubImportFailed(:final failure):
              _showFailure(context, failure);
              return;
          }
      }
    } on Object {
      if (mounted) {
        _showFailure(context, AppFailure.fromCode(AppErrorCode.storageFailed));
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _chooseMangaSource() async {
    final kind = await showModalBottomSheet<MangaSourceKind>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('import-manga-archive'),
              leading: const Icon(Icons.folder_zip_outlined),
              title: const Text('选择 ZIP / CBZ'),
              onTap: () => Navigator.pop(sheetContext, MangaSourceKind.archive),
            ),
            ListTile(
              key: const Key('import-manga-directory'),
              leading: const Icon(Icons.folder_outlined),
              title: const Text('选择漫画目录'),
              onTap: () =>
                  Navigator.pop(sheetContext, MangaSourceKind.directory),
            ),
          ],
        ),
      ),
    );
    if (kind == null || !mounted) return;
    await _importManga(kind);
  }

  Future<void> _importManga(MangaSourceKind kind) async {
    setState(() => _importing = true);
    try {
      final preparation =
          await widget.prepareMangaForImport?.call(kind) ??
          await ref.read(prepareMangaSourceProvider)(kind);
      if (!mounted) return;
      switch (preparation) {
        case MangaSourceCancelled():
          return;
        case MangaSourceDuplicate(:final mediaItemId):
          widget.onOpenManga?.call(mediaItemId);
          return;
        case MangaSourceFailed(:final failure):
          _showFailure(context, failure);
          return;
        case MangaSourceReady(:final candidate):
          final importer = widget.completeMangaImport;
          final result = importer != null
              ? await importer(candidate)
              : await (await ref.read(importMangaProvider.future))(candidate);
          if (!mounted) return;
          switch (result) {
            case MangaImportSucceeded(:final mediaItemId):
              ref.invalidate(activeLibraryProvider);
              widget.onOpenManga?.call(mediaItemId);
            case MangaImportDuplicate(:final mediaItemId):
              widget.onOpenManga?.call(mediaItemId);
            case MangaImportFailed(:final failure):
              _showFailure(context, failure);
          }
      }
    } on Object {
      if (mounted) {
        _showFailure(context, AppFailure.fromCode(AppErrorCode.storageFailed));
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<String?> _requestTitle() {
    return showDialog<String>(
      context: context,
      builder: (_) => const _ImportTitleDialog(),
    );
  }

  Future<TxtEncoding?> _requestEncoding(List<TxtEncoding> encodings) {
    return showDialog<TxtEncoding>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('选择文本编码'),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text('无法可靠自动识别。请选择编码后严格重试，不会静默替换乱码。'),
          ),
          for (final encoding in encodings)
            SimpleDialogOption(
              key: Key('encoding-${encoding.storageValue}'),
              onPressed: () => Navigator.of(dialogContext).pop(encoding),
              child: Text(_encodingLabel(encoding)),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    LibraryItem item,
  ) async {
    final result = await ref
        .read(libraryActionsProvider.notifier)
        .open(item.mediaItem.id);
    if (context.mounted && result == LibraryActionResult.failed) {
      _showMessage(context, '无法打开这本书，请重试。');
      return;
    }
    if (context.mounted && result == LibraryActionResult.succeeded) {
      if (item.mediaItem.mediaType == MediaType.manga) {
        widget.onOpenManga?.call(item.mediaItem.id);
      } else {
        widget.onOpenNovel(item.mediaItem.id);
      }
    }
  }

  Future<void> _confirmArchive(
    BuildContext context,
    WidgetRef ref,
    LibraryItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('归档《${item.mediaItem.title}》？'),
        content: const Text('作品会移入“已归档”，不会删除原文件。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('移入归档'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final mediaId = item.mediaItem.id;
    final result = await ref
        .read(libraryActionsProvider.notifier)
        .archive(mediaId);
    if (!context.mounted) {
      return;
    }
    if (result == LibraryActionResult.failed) {
      _showMessage(context, '无法归档，请重试。');
      return;
    }
    if (result == LibraryActionResult.succeeded) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Text('已移入归档'),
            action: SnackBarAction(
              label: '撤销',
              onPressed: () => unawaited(_undoArchive(context, ref, mediaId)),
            ),
          ),
        );
    }
  }

  Future<void> _openOrganization(LibraryItem item) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _OrganizationSheet(item: item),
    );
  }

  Future<void> _openOrganizationManagement() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _OrganizationManagementSheet(),
    );
  }

  Future<void> _undoArchive(
    BuildContext context,
    WidgetRef ref,
    String mediaId,
  ) async {
    final result = await ref
        .read(libraryActionsProvider.notifier)
        .restore(mediaId);
    if (context.mounted && result == LibraryActionResult.failed) {
      _showMessage(context, '无法恢复，请重试。');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showFailure(BuildContext context, AppFailure failure) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(failure.message),
              if (failure.recovery case final recovery?) Text(recovery),
            ],
          ),
        ),
      );
  }
}

class _OrganizationSheet extends ConsumerWidget {
  const _OrganizationSheet({required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaId = item.mediaItem.id;
    final tags = ref.watch(organizationTagsProvider);
    final shelves = ref.watch(organizationShelvesProvider);
    final selectedTags = ref.watch(mediaTagIdsProvider(mediaId));
    final selectedShelves = ref.watch(mediaShelfIdsProvider(mediaId));
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.82,
        child: ListView(
          key: const Key('organization-sheet'),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            Text(
              '整理《${item.mediaItem.title}》',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _OrganizationHeader(
              title: '标签',
              actionLabel: '新建标签',
              onAdd: () => _createTag(context, ref),
            ),
            _OrganizationChoices(
              values: tags,
              selectedIds: selectedTags,
              emptyText: '还没有标签',
              idOf: (value) => value.id,
              nameOf: (value) => value.name,
              onChanged: (id, selected) => ref
                  .read(libraryOrganizationRepositoryProvider)
                  .setTagAssigned(
                    tagId: id,
                    mediaItemId: mediaId,
                    assigned: selected,
                    changedAt: DateTime.now().toUtc(),
                  ),
            ),
            const Divider(height: 32),
            _OrganizationHeader(
              title: '自定义书架',
              actionLabel: '新建书架',
              onAdd: () => _createShelf(context, ref),
            ),
            _OrganizationChoices(
              values: shelves,
              selectedIds: selectedShelves,
              emptyText: '还没有自定义书架',
              idOf: (value) => value.id,
              nameOf: (value) => value.name,
              onChanged: (id, selected) => ref
                  .read(libraryOrganizationRepositoryProvider)
                  .setMediaInShelf(
                    shelfId: id,
                    mediaItemId: mediaId,
                    included: selected,
                    changedAt: DateTime.now().toUtc(),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTag(BuildContext context, WidgetRef ref) async {
    final name = await _requestOrganizationName(context, '新建标签');
    if (name == null) return;
    try {
      await ref
          .read(libraryOrganizationRepositoryProvider)
          .createTag(
            MediaTag(
              id: const UuidIdGenerator().newId(),
              name: name,
              createdAt: DateTime.now().toUtc(),
            ),
          );
    } on Object {
      if (context.mounted) _showOrganizationFailure(context);
    }
  }

  Future<void> _createShelf(BuildContext context, WidgetRef ref) async {
    final name = await _requestOrganizationName(context, '新建书架');
    if (name == null) return;
    final now = DateTime.now().toUtc();
    try {
      await ref
          .read(libraryOrganizationRepositoryProvider)
          .createShelf(
            CustomShelf(
              id: const UuidIdGenerator().newId(),
              name: name,
              createdAt: now,
              updatedAt: now,
            ),
          );
    } on Object {
      if (context.mounted) _showOrganizationFailure(context);
    }
  }
}

enum _OrganizationMenuAction { rename, delete }

class _OrganizationManagementSheet extends ConsumerWidget {
  const _OrganizationManagementSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(organizationTagsProvider);
    final shelves = ref.watch(organizationShelvesProvider);
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.82,
        child: ListView(
          key: const Key('organization-management-sheet'),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            Text('标签与书架管理', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Text('标签', style: Theme.of(context).textTheme.titleMedium),
            _ManagementList<MediaTag>(
              values: tags,
              emptyText: '还没有标签',
              keyPrefix: 'manage-tag',
              idOf: (tag) => tag.id,
              nameOf: (tag) => tag.name,
              onRename: (tag) => _renameTag(context, ref, tag),
              onDelete: (tag) => _deleteTag(context, ref, tag),
            ),
            const Divider(height: 32),
            Text('自定义书架', style: Theme.of(context).textTheme.titleMedium),
            _ManagementList<CustomShelf>(
              values: shelves,
              emptyText: '还没有自定义书架',
              keyPrefix: 'manage-shelf',
              idOf: (shelf) => shelf.id,
              nameOf: (shelf) => shelf.name,
              onRename: (shelf) => _renameShelf(context, ref, shelf),
              onDelete: (shelf) => _deleteShelf(context, ref, shelf),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renameTag(
    BuildContext context,
    WidgetRef ref,
    MediaTag tag,
  ) async {
    final name = await _requestOrganizationName(
      context,
      '重命名标签',
      initialValue: tag.name,
      actionLabel: '保存',
    );
    if (name == null || name == tag.name) return;
    try {
      await ref
          .read(libraryOrganizationRepositoryProvider)
          .renameTag(tag.id, name);
    } on Object {
      if (context.mounted) _showOrganizationFailure(context);
    }
  }

  Future<void> _renameShelf(
    BuildContext context,
    WidgetRef ref,
    CustomShelf shelf,
  ) async {
    final name = await _requestOrganizationName(
      context,
      '重命名书架',
      initialValue: shelf.name,
      actionLabel: '保存',
    );
    if (name == null || name == shelf.name) return;
    try {
      await ref
          .read(libraryOrganizationRepositoryProvider)
          .renameShelf(shelf.id, name, DateTime.now().toUtc());
    } on Object {
      if (context.mounted) _showOrganizationFailure(context);
    }
  }

  Future<void> _deleteTag(
    BuildContext context,
    WidgetRef ref,
    MediaTag tag,
  ) async {
    if (!await _confirmOrganizationDelete(context, '标签', tag.name)) return;
    try {
      await ref.read(libraryOrganizationRepositoryProvider).deleteTag(tag.id);
    } on Object {
      if (context.mounted) _showOrganizationFailure(context);
    }
  }

  Future<void> _deleteShelf(
    BuildContext context,
    WidgetRef ref,
    CustomShelf shelf,
  ) async {
    if (!await _confirmOrganizationDelete(context, '书架', shelf.name)) return;
    try {
      await ref
          .read(libraryOrganizationRepositoryProvider)
          .deleteShelf(shelf.id);
    } on Object {
      if (context.mounted) _showOrganizationFailure(context);
    }
  }
}

class _ManagementList<T> extends StatelessWidget {
  const _ManagementList({
    required this.values,
    required this.emptyText,
    required this.keyPrefix,
    required this.idOf,
    required this.nameOf,
    required this.onRename,
    required this.onDelete,
  });

  final AsyncValue<List<T>> values;
  final String emptyText;
  final String keyPrefix;
  final String Function(T) idOf;
  final String Function(T) nameOf;
  final ValueChanged<T> onRename;
  final ValueChanged<T> onDelete;

  @override
  Widget build(BuildContext context) => values.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (_, _) => const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text('加载失败，请重试。'),
    ),
    data: (items) => items.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(emptyText),
          )
        : Column(
            children: [
              for (final value in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(nameOf(value)),
                  trailing: PopupMenuButton<_OrganizationMenuAction>(
                    key: Key('$keyPrefix-${idOf(value)}'),
                    tooltip: '管理${nameOf(value)}',
                    onSelected: (action) {
                      switch (action) {
                        case _OrganizationMenuAction.rename:
                          onRename(value);
                        case _OrganizationMenuAction.delete:
                          onDelete(value);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: _OrganizationMenuAction.rename,
                        child: Text('重命名'),
                      ),
                      PopupMenuItem(
                        value: _OrganizationMenuAction.delete,
                        child: Text('删除'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
  );
}

Future<bool> _confirmOrganizationDelete(
  BuildContext context,
  String type,
  String name,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('删除$type“$name”？'),
          content: Text('只会删除$type及其整理关系，不会删除媒体或原始文件。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('删除'),
            ),
          ],
        ),
      ) ??
      false;
}

class _OrganizationHeader extends StatelessWidget {
  const _OrganizationHeader({
    required this.title,
    required this.actionLabel,
    required this.onAdd,
  });
  final String title;
  final String actionLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      TextButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: Text(actionLabel),
      ),
    ],
  );
}

class _OrganizationChoices<T> extends StatelessWidget {
  const _OrganizationChoices({
    required this.values,
    required this.selectedIds,
    required this.emptyText,
    required this.idOf,
    required this.nameOf,
    required this.onChanged,
  });
  final AsyncValue<List<T>> values;
  final AsyncValue<Set<String>> selectedIds;
  final String emptyText;
  final String Function(T) idOf;
  final String Function(T) nameOf;
  final Future<void> Function(String, bool) onChanged;

  @override
  Widget build(BuildContext context) => values.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (_, _) => const Text('加载失败，请重试。'),
    data: (items) => selectedIds.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Text('加载失败，请重试。'),
      data: (selected) => items.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(emptyText),
            )
          : Column(
              children: [
                for (final value in items)
                  CheckboxListTile(
                    key: Key('organization-${idOf(value)}'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(nameOf(value)),
                    value: selected.contains(idOf(value)),
                    onChanged: (checked) {
                      if (checked != null) {
                        unawaited(_change(context, idOf(value), checked));
                      }
                    },
                  ),
              ],
            ),
    ),
  );

  Future<void> _change(BuildContext context, String id, bool selected) async {
    try {
      await onChanged(id, selected);
    } on Object {
      if (context.mounted) _showOrganizationFailure(context);
    }
  }
}

void _showOrganizationFailure(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(const SnackBar(content: Text('无法保存，名称可能已存在，请重试。')));
}

Future<String?> _requestOrganizationName(
  BuildContext context,
  String title, {
  String initialValue = '',
  String actionLabel = '创建',
}) async {
  final controller = TextEditingController(text: initialValue);
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextField(
        key: const Key('organization-name-field'),
        controller: controller,
        autofocus: true,
        maxLength: 60,
        decoration: const InputDecoration(labelText: '名称'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) Navigator.pop(dialogContext, name);
          },
          child: Text(actionLabel),
        ),
      ],
    ),
  );
  return result;
}

class _LibraryFilterSheet extends StatefulWidget {
  const _LibraryFilterSheet({required this.initialQuery});

  final LibraryQuery initialQuery;

  @override
  State<_LibraryFilterSheet> createState() => _LibraryFilterSheetState();
}

class _LibraryFilterSheetState extends State<_LibraryFilterSheet> {
  late Set<MediaType> _mediaTypes;
  late bool _favoriteOnly;
  late LibrarySort _sort;

  @override
  void initState() {
    super.initState();
    _mediaTypes = {...widget.initialQuery.mediaTypes};
    _favoriteOnly = widget.initialQuery.favoriteOnly;
    _sort = widget.initialQuery.sort;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        children: [
          Text('筛选和排序', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          Text('类型', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                key: const Key('filter-media-novel'),
                label: const Text('小说'),
                selected: _mediaTypes.contains(MediaType.novel),
                onSelected: (selected) =>
                    _setMediaType(MediaType.novel, selected),
              ),
              FilterChip(
                key: const Key('filter-media-manga'),
                label: const Text('漫画'),
                selected: _mediaTypes.contains(MediaType.manga),
                onSelected: (selected) =>
                    _setMediaType(MediaType.manga, selected),
              ),
              FilterChip(
                key: const Key('filter-favorite-only'),
                label: const Text('仅收藏'),
                selected: _favoriteOnly,
                onSelected: (selected) =>
                    setState(() => _favoriteOnly = selected),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('排序', style: Theme.of(context).textTheme.titleMedium),
          RadioGroup<LibrarySort>(
            groupValue: _sort,
            onChanged: (value) {
              if (value != null) setState(() => _sort = value);
            },
            child: Column(
              children: [
                for (final option in LibrarySort.values)
                  RadioListTile<LibrarySort>(
                    key: Key('sort-${option.name}'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(_sortLabel(option)),
                    value: option,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                key: const Key('reset-library-filters'),
                onPressed: _reset,
                child: const Text('重置'),
              ),
              const Spacer(),
              TextButton(
                key: const Key('cancel-library-filters'),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: const Key('apply-library-filters'),
                onPressed: _apply,
                child: const Text('应用'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _setMediaType(MediaType type, bool selected) {
    setState(() {
      if (selected) {
        _mediaTypes.add(type);
      } else {
        _mediaTypes.remove(type);
      }
    });
  }

  void _reset() {
    setState(() {
      _mediaTypes.clear();
      _favoriteOnly = false;
      _sort = LibrarySort.recentlyOpened;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      widget.initialQuery.copyWith(
        mediaTypes: Set.unmodifiable(_mediaTypes),
        favoriteOnly: _favoriteOnly,
        sort: _sort,
      ),
    );
  }
}

String _sortLabel(LibrarySort sort) => switch (sort) {
  LibrarySort.recentlyOpened => '最近阅读',
  LibrarySort.recentlyAdded => '最近加入',
  LibrarySort.titleAscending => '书名 A–Z',
  LibrarySort.titleDescending => '书名 Z–A',
};

class _ImportTitleDialog extends StatefulWidget {
  const _ImportTitleDialog();

  @override
  State<_ImportTitleDialog> createState() => _ImportTitleDialogState();
}

class _ImportTitleDialogState extends State<_ImportTitleDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('确认书名'),
      content: TextField(
        key: const Key('import-title'),
        controller: _controller,
        autofocus: true,
        maxLength: 200,
        decoration: const InputDecoration(
          labelText: '书名',
          hintText: '输入这本小说在媒体库中的名称',
        ),
        onSubmitted: _submit,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const Key('confirm-import-title'),
          onPressed: () => _submit(_controller.text),
          child: const Text('继续'),
        ),
      ],
    );
  }

  void _submit(String value) {
    final title = value.trim();
    if (title.isNotEmpty) Navigator.of(context).pop(title);
  }
}

String _encodingLabel(TxtEncoding encoding) => switch (encoding) {
  TxtEncoding.utf8 => 'UTF-8',
  TxtEncoding.utf16le => 'UTF-16 LE',
  TxtEncoding.utf16be => 'UTF-16 BE',
  TxtEncoding.gb18030 => 'GB18030',
};
