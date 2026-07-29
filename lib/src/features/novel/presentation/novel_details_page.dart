import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/novel_providers.dart';
import '../domain/novel_details.dart';

class NovelDetailsPage extends ConsumerWidget {
  const NovelDetailsPage({
    required this.mediaItemId,
    required this.onStartReading,
    this.onRelocateSource,
    super.key,
  });

  final String mediaItemId;
  final VoidCallback onStartReading;
  final VoidCallback? onRelocateSource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(novelDetailsProvider(mediaItemId));
    return Scaffold(
      appBar: AppBar(title: const Text('小说详情')),
      body: details.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _ErrorState(
          onRetry: () => ref.invalidate(novelDetailsProvider(mediaItemId)),
        ),
        data: (value) => value == null
            ? const Center(child: Text('找不到这部作品'))
            : _DetailsBody(
                details: value,
                onStartReading: onStartReading,
                onRelocateSource: onRelocateSource,
              ),
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({
    required this.details,
    required this.onStartReading,
    this.onRelocateSource,
  });

  final NovelDetails details;
  final VoidCallback onStartReading;
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
                Text(
                  details.mediaItem.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text('共 ${details.chapters.length} 章'),
                const SizedBox(height: 16),
                if (details.sourceAvailable)
                  FilledButton.icon(
                    onPressed: onStartReading,
                    icon: const Icon(Icons.menu_book),
                    label: const Text('开始阅读'),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Expanded(child: Text('源文件已移动或不可用，请重新定位。')),
                          TextButton(
                            onPressed: onRelocateSource,
                            child: const Text('重新定位源文件'),
                          ),
                        ],
                      ),
                    ),
                  ),
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
            return ListTile(
              leading: Text('${index + 1}'),
              title: Text(
                chapter.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: details.sourceAvailable ? onStartReading : null,
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
