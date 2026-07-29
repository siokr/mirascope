import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirascope/src/shared/widgets/empty_state.dart';

import '../application/library_actions_controller.dart';
import '../application/library_providers.dart';
import '../domain/library_item.dart';
import '../domain/media_item.dart';
import 'widgets/library_error_state.dart';
import 'widgets/library_grid.dart';
import 'widgets/library_loading_grid.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({
    required this.onOpenSettings,
    required this.onOpenArchive,
    required this.onOpenNovel,
    super.key,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onOpenArchive;
  final ValueChanged<String> onOpenNovel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(activeLibraryProvider);
    final busyMediaIds = ref.watch(libraryActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('媒体库'),
        actions: [
          IconButton(
            key: const Key('open-archive'),
            onPressed: onOpenArchive,
            tooltip: '已归档',
            icon: const Icon(Icons.inventory_2_outlined),
          ),
          IconButton(
            key: const Key('open-settings'),
            onPressed: onOpenSettings,
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
        .open(item.mediaItem.id, onReady: () => onOpenNovel(item.mediaItem.id));
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
