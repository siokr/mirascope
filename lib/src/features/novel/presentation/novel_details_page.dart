import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../importing/application/importing_providers.dart';
import '../../importing/application/relocate_txt_source.dart';
import '../../importing/domain/import_record.dart';
import '../../library/presentation/edit_media_metadata_dialog.dart';
import '../../library/presentation/media_metadata_summary.dart';
import '../application/novel_providers.dart';
import '../domain/novel_details.dart';

class NovelDetailsPage extends ConsumerStatefulWidget {
  const NovelDetailsPage({
    required this.mediaItemId,
    required this.onStartReading,
    this.onRelocateSource,
    super.key,
  });

  final String mediaItemId;
  final ValueChanged<String?> onStartReading;
  final VoidCallback? onRelocateSource;

  @override
  ConsumerState<NovelDetailsPage> createState() => _NovelDetailsPageState();
}

class _NovelDetailsPageState extends ConsumerState<NovelDetailsPage> {
  var _relocating = false;

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(novelDetailsProvider(widget.mediaItemId));
    return Scaffold(
      appBar: AppBar(title: const Text('小说详情')),
      body: details.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _ErrorState(
          onRetry: () =>
              ref.invalidate(novelDetailsProvider(widget.mediaItemId)),
        ),
        data: (value) => value == null
            ? const Center(child: Text('找不到这部作品'))
            : _DetailsBody(
                details: value,
                onStartReading: widget.onStartReading,
                onEditMetadata: () => _editMetadata(value),
                onRelocateSource:
                    widget.onRelocateSource ??
                    (_relocating ? null : _relocateSource),
              ),
      ),
    );
  }

  Future<void> _editMetadata(NovelDetails details) async {
    final saved = await showEditMediaMetadataDialog(
      context,
      mediaItem: details.mediaItem,
    );
    if (!mounted || !saved) return;
    ref.invalidate(novelDetailsProvider(widget.mediaItemId));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('作品信息已保存')));
  }

  Future<void> _relocateSource() async {
    setState(() => _relocating = true);
    final details = await ref.read(
      novelDetailsProvider(widget.mediaItemId).future,
    );
    final result = details?.sourceKind == ImportSourceKind.epubFile
        ? await ref.read(relocateEpubSourceProvider)(widget.mediaItemId)
        : await ref.read(relocateTxtSourceProvider)(widget.mediaItemId);
    if (!mounted) return;
    setState(() => _relocating = false);

    switch (result) {
      case SourceRelocationCancelled():
        return;
      case SourceRelocated():
        ref.invalidate(novelDetailsProvider(widget.mediaItemId));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('源文件已重新关联')));
        return;
      case SourceChangeConfirmationRequired():
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('文件内容不同'),
            content: const Text(
              '所选文件不是原文件的同一内容，不能直接替换。'
              '当前可读版本和阅读进度已保留。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('保留当前版本'),
              ),
            ],
          ),
        );
        return;
      case SourceRelocationFailed(:final failure):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
        return;
    }
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({
    required this.details,
    required this.onStartReading,
    required this.onEditMetadata,
    this.onRelocateSource,
  });

  final NovelDetails details;
  final ValueChanged<String?> onStartReading;
  final VoidCallback onEditMetadata;
  final VoidCallback? onRelocateSource;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        details.mediaItem.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    IconButton(
                      key: const Key('edit-media-metadata'),
                      onPressed: onEditMetadata,
                      tooltip: '编辑作品信息',
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
                MediaMetadataSummary(mediaItem: details.mediaItem),
                const SizedBox(height: 8),
                Text('共 ${details.chapters.length} 章'),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: details.chapters.isEmpty
                      ? null
                      : () => onStartReading(null),
                  icon: const Icon(Icons.menu_book),
                  label: const Text('开始阅读'),
                ),
                if (!details.sourceAvailable) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const message = Text('源文件已移动或不可用，请重新定位。');
                          final action = TextButton(
                            onPressed: onRelocateSource,
                            child: const Text('重新定位源文件'),
                          );
                          if (constraints.maxWidth < 520) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                message,
                                const SizedBox(height: 8),
                                action,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: message),
                              action,
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text('目录', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: details.chapters.length,
          itemBuilder: (context, index) {
            final chapter = details.chapters[index];
            return Semantics(
              button: true,
              label: '第 ${index + 1} 章，${chapter.title}',
              onTap: () => onStartReading(chapter.id),
              child: ExcludeSemantics(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: Text('${index + 1}'),
                  title: Text(
                    chapter.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => onStartReading(chapter.id),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('无法加载小说详情'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
