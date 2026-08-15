import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../importing/application/importing_providers.dart';
import '../../importing/application/relocate_txt_source.dart';
import '../../importing/domain/import_record.dart';
import '../../importing/domain/manga_source.dart';
import '../application/manga_providers.dart';

class MangaDetailsPage extends ConsumerStatefulWidget {
  const MangaDetailsPage({
    required this.mediaItemId,
    required this.onOpenChapter,
    required this.onContinueReading,
    super.key,
  });
  final String mediaItemId;
  final ValueChanged<String> onOpenChapter;
  final VoidCallback onContinueReading;

  @override
  ConsumerState<MangaDetailsPage> createState() => _MangaDetailsPageState();
}

class _MangaDetailsPageState extends ConsumerState<MangaDetailsPage> {
  var _relocating = false;

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(mangaDetailsProvider(widget.mediaItemId));
    return Scaffold(
      appBar: AppBar(title: const Text('漫画详情')),
      body: details.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('无法加载漫画详情')),
        data: (value) {
          if (value == null) return const Center(child: Text('漫画不存在或已删除'));
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                value.mediaItem.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text('共 ${value.chapters.length} 章 · ${value.pageCount} 页'),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  key: const Key('continue-manga-reading'),
                  onPressed: value.sourceAvailable
                      ? widget.onContinueReading
                      : null,
                  icon: const Icon(Icons.menu_book),
                  label: const Text('开始阅读'),
                ),
              ),
              if (!value.sourceAvailable) ...[
                const Card(
                  margin: EdgeInsets.only(top: 20),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('源文件已移动或不可用。漫画记录和阅读进度仍会保留。'),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('relocate-manga-source'),
                    onPressed: _relocating
                        ? null
                        : () => _relocate(value.sourceKind),
                    icon: const Icon(Icons.folder_open_outlined),
                    label: Text(_relocating ? '正在重新定位' : '重新定位源文件'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text('目录', style: Theme.of(context).textTheme.titleLarge),
              for (final chapter in value.chapters)
                ListTile(
                  key: Key('manga-chapter-${chapter.unit.id}'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(chapter.unit.title),
                  subtitle: Text('${chapter.pageCount} 页'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: value.sourceAvailable
                      ? () => widget.onOpenChapter(chapter.unit.id)
                      : null,
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _relocate(ImportSourceKind? sourceKind) async {
    final kind = sourceKind == ImportSourceKind.mangaDirectory
        ? MangaSourceKind.directory
        : MangaSourceKind.archive;
    setState(() => _relocating = true);
    final result = await ref.read(relocateMangaSourceProvider)(
      widget.mediaItemId,
      kind,
    );
    if (!mounted) return;
    setState(() => _relocating = false);
    switch (result) {
      case SourceRelocationCancelled():
        return;
      case SourceRelocated():
        ref.invalidate(mangaDetailsProvider(widget.mediaItemId));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('源文件已重新关联')));
      case SourceChangeConfirmationRequired():
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('文件内容不同'),
            content: const Text('所选来源不是原漫画的同一内容，不能直接替换。现有记录和阅读进度已保留。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('保留当前版本'),
              ),
            ],
          ),
        );
      case SourceRelocationFailed(:final failure):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }
}
