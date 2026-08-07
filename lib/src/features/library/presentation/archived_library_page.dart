import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirascope/src/shared/widgets/empty_state.dart';

import '../application/library_actions_controller.dart';
import '../application/library_providers.dart';
import '../domain/library_item.dart';
import 'widgets/library_error_state.dart';
import 'widgets/library_grid.dart';
import 'widgets/library_loading_grid.dart';

class ArchivedLibraryPage extends ConsumerWidget {
  const ArchivedLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(archivedLibraryProvider);
    final busyMediaIds = ref.watch(libraryActionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('已归档')),
      body: library.when(
        loading: () => const LibraryLoadingGrid(),
        error: (_, _) => LibraryErrorState(
          onRetry: () => ref.invalidate(archivedLibraryProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: '没有已归档内容',
              message: '归档的作品会保留在这里，也不会删除原文件。',
            );
          }
          return LibraryGrid(
            items: items,
            archived: true,
            busyMediaIds: busyMediaIds,
            onOpen: (_) {},
            onArchive: (_) {},
            onRestore: (item) => unawaited(_restore(context, ref, item)),
            onDelete: (item) => unawaited(_confirmDelete(context, ref, item)),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LibraryItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('永久删除《${item.mediaItem.title}》？'),
        content: const Text(
          '将删除应用内的书籍、章节、阅读进度、阅读设置和派生正文。'
          '不会删除原始小说文件。此操作无法撤销，删除后可以重新导入。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('confirm-permanent-delete'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('永久删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result = await ref
        .read(libraryActionsProvider.notifier)
        .delete(item.mediaItem.id);
    if (!context.mounted) return;
    final message = switch (result) {
      LibraryActionResult.succeeded => '已永久删除，可重新导入',
      LibraryActionResult.failed => '无法删除，请重试。',
      LibraryActionResult.busy => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    LibraryItem item,
  ) async {
    final result = await ref
        .read(libraryActionsProvider.notifier)
        .restore(item.mediaItem.id);
    if (!context.mounted) {
      return;
    }

    final message = switch (result) {
      LibraryActionResult.succeeded => '已恢复到媒体库',
      LibraryActionResult.failed => '无法恢复，请重试。',
      LibraryActionResult.busy => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
