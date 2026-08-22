import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../library/domain/media_item.dart';
import '../application/history_providers.dart';
import '../domain/library_statistics.dart';
import '../domain/reading_history_item.dart';

class ReadingHistoryPage extends ConsumerWidget {
  const ReadingHistoryPage({
    required this.onOpenNovel,
    required this.onOpenManga,
    super.key,
  });

  final ValueChanged<String> onOpenNovel;
  final ValueChanged<String> onOpenManga;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistics = ref.watch(libraryStatisticsProvider);
    final history = ref.watch(recentReadingHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('阅读历史')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          statistics.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const _SafeError(message: '无法加载统计，请稍后重试。'),
            data: _StatisticsSummary.new,
          ),
          const SizedBox(height: 28),
          Text('最近阅读', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          history.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, _) => const _SafeError(message: '无法加载阅读历史，请稍后重试。'),
            data: (items) => items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('还没有阅读记录。打开一本书后会显示在这里。'),
                  )
                : Column(
                    children: [
                      for (final item in items)
                        ListTile(
                          key: Key('history-${item.mediaItemId}'),
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            item.mediaType == MediaType.manga
                                ? Icons.collections_bookmark_outlined
                                : Icons.menu_book_outlined,
                          ),
                          title: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(_historySubtitle(item)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => item.mediaType == MediaType.manga
                              ? onOpenManga(item.mediaItemId)
                              : onOpenNovel(item.mediaItemId),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatisticsSummary extends StatelessWidget {
  const _StatisticsSummary(this.statistics);

  final LibraryStatistics statistics;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      _StatChip(label: '媒体 ${statistics.totalMedia}'),
      _StatChip(label: '已开始 ${statistics.startedMedia}'),
      _StatChip(label: '收藏 ${statistics.favoriteMedia}'),
      _StatChip(label: '小说 ${statistics.novelMedia}'),
      _StatChip(label: '漫画 ${statistics.mangaMedia}'),
    ],
  );
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Chip(label: Text(label));
}

class _SafeError extends StatelessWidget {
  const _SafeError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(message),
  );
}

String _historySubtitle(ReadingHistoryItem item) {
  final opened = item.lastOpenedAt.toLocal();
  final date =
      '${opened.year}/${opened.month.toString().padLeft(2, '0')}/'
      '${opened.day.toString().padLeft(2, '0')}';
  if (item.fraction case final fraction?) {
    return '最近阅读 $date · 当前章节 ${(fraction * 100).round()}%';
  }
  return '最近阅读 $date';
}
