import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/novel_providers.dart';
import '../application/novel_reader_controller.dart';

class NovelReaderPage extends ConsumerWidget {
  const NovelReaderPage({required this.mediaItemId, super.key});

  final String mediaItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(novelReaderControllerProvider(mediaItemId));
    return controller.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: const Text('阅读器')),
        body: Center(
          child: OutlinedButton(
            onPressed: () =>
                ref.invalidate(novelReaderControllerProvider(mediaItemId)),
            child: const Text('重试'),
          ),
        ),
      ),
      data: (value) => _ReaderScaffold(controller: value),
    );
  }
}

class _ReaderScaffold extends StatefulWidget {
  const _ReaderScaffold({required this.controller});
  final NovelReaderController controller;

  @override
  State<_ReaderScaffold> createState() => _ReaderScaffoldState();
}

class _ReaderScaffoldState extends State<_ReaderScaffold> {
  final ScrollController _scrollController = ScrollController();
  var _lastChapterIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        if (controller.chapter != null &&
            controller.currentIndex != _lastChapterIndex) {
          _lastChapterIndex = controller.currentIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(0);
            }
          });
        }
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowLeft):
                controller.previous,
            const SingleActivator(LogicalKeyboardKey.pageUp):
                controller.previous,
            const SingleActivator(LogicalKeyboardKey.arrowRight):
                controller.next,
            const SingleActivator(LogicalKeyboardKey.pageDown): controller.next,
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              appBar: AppBar(
                title: Text(controller.chapter?.unit.title ?? '阅读器'),
              ),
              drawer: _ChapterDrawer(controller: controller),
              body: _body(controller),
              bottomNavigationBar: controller.chapter == null
                  ? null
                  : SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: controller.canGoPrevious
                                  ? controller.previous
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                              label: const Text('上一章'),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${controller.currentIndex + 1} / '
                              '${controller.book!.chapters.length}',
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              onPressed: controller.canGoNext
                                  ? controller.next
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                              label: const Text('下一章'),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(NovelReaderController controller) {
    if (controller.initialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.chapter == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(controller.errorMessage ?? '无法打开阅读内容'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: controller.retry,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    return Stack(
      children: [
        SelectionArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 80),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  controller.chapter!.text,
                  style: const TextStyle(fontSize: 18, height: 1.8),
                ),
              ),
            ),
          ),
        ),
        if (controller.loadingIndex != null)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
        if (controller.errorMessage != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: MaterialBanner(
              content: Text(controller.errorMessage!),
              actions: [
                TextButton(
                  onPressed: controller.retry,
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ChapterDrawer extends StatelessWidget {
  const _ChapterDrawer({required this.controller});
  final NovelReaderController controller;

  @override
  Widget build(BuildContext context) {
    final chapters = controller.book?.chapters ?? const [];
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const ListTile(title: Text('目录')),
            Expanded(
              child: ListView.builder(
                itemCount: chapters.length,
                itemBuilder: (context, index) => ListTile(
                  selected: index == controller.currentIndex,
                  title: Text(
                    chapters[index].title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.select(index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
