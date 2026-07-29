import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirascope/src/shared/widgets/empty_state.dart';

import '../../importing/application/import_txt.dart';
import '../../importing/application/importing_providers.dart';
import '../../importing/application/prepare_txt_source.dart';
import '../../importing/domain/txt_encoding.dart';
import '../../importing/domain/txt_source_candidate.dart';
import '../application/library_actions_controller.dart';
import '../application/library_providers.dart';
import '../domain/library_item.dart';
import '../domain/media_item.dart';
import 'widgets/library_error_state.dart';
import 'widgets/library_grid.dart';
import 'widgets/library_loading_grid.dart';

typedef PrepareTxtForImport = Future<TxtSourcePreparationResult> Function();
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
    this.prepareTxtForImport,
    this.completeTxtImport,
    super.key,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onOpenArchive;
  final ValueChanged<String> onOpenNovel;
  final PrepareTxtForImport? prepareTxtForImport;
  final CompleteTxtImport? completeTxtImport;

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  var _importing = false;

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(activeLibraryProvider);
    final busyMediaIds = ref.watch(libraryActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('媒体库'),
        actions: [
          IconButton(
            key: const Key('open-archive'),
            onPressed: widget.onOpenArchive,
            tooltip: '已归档',
            icon: const Icon(Icons.inventory_2_outlined),
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
            return const EmptyState(
              icon: Icons.menu_book_outlined,
              title: '媒体库还是空的',
              message: '导入 TXT 小说后，它会出现在这里。',
            );
          }
          return LibraryGrid(
            items: items,
            archived: false,
            busyMediaIds: busyMediaIds,
            onOpen: (item) => unawaited(_open(context, ref, item)),
            onArchive: (item) => unawaited(_confirmArchive(context, ref, item)),
            onRestore: (_) {},
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('import-txt'),
        onPressed: _importing ? null : _importTxt,
        icon: _importing
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: Text(_importing ? '正在导入' : '导入 TXT'),
      ),
    );
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
          _showMessage(context, failure.message);
          return;
        case TxtSourceReady(:final candidate):
          final title = await _requestTitle();
          if (title == null || !mounted) return;
          await _completeImport(candidate, title);
          return;
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
        _showMessage(context, failure.message);
        return;
    }
  }

  Future<String?> _requestTitle() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认书名'),
        content: TextField(
          key: const Key('import-title'),
          controller: controller,
          autofocus: true,
          maxLength: 200,
          decoration: const InputDecoration(
            labelText: '书名',
            hintText: '输入这本小说在媒体库中的名称',
          ),
          onSubmitted: (value) {
            final title = value.trim();
            if (title.isNotEmpty) Navigator.of(dialogContext).pop(title);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('confirm-import-title'),
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) Navigator.of(dialogContext).pop(title);
            },
            child: const Text('继续'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
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
    if (item.mediaItem.mediaType != MediaType.novel) {
      _showMessage(context, '当前版本还不能打开这类内容。');
      return;
    }

    final result = await ref
        .read(libraryActionsProvider.notifier)
        .open(
          item.mediaItem.id,
          onReady: () => widget.onOpenNovel(item.mediaItem.id),
        );
    if (context.mounted && result == LibraryActionResult.failed) {
      _showMessage(context, '无法打开这本书，请重试。');
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
}

String _encodingLabel(TxtEncoding encoding) => switch (encoding) {
  TxtEncoding.utf8 => 'UTF-8',
  TxtEncoding.utf16le => 'UTF-16 LE',
  TxtEncoding.utf16be => 'UTF-16 BE',
  TxtEncoding.gb18030 => 'GB18030',
};
