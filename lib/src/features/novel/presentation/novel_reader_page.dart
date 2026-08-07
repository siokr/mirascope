import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/reader_settings_controller.dart';
import '../application/novel_providers.dart';
import '../application/novel_reader_controller.dart';
import '../domain/reader_book.dart';

class NovelReaderPage extends ConsumerWidget {
  const NovelReaderPage({
    required this.mediaItemId,
    required this.onExit,
    this.initialContentUnitId,
    super.key,
  });

  final String mediaItemId;
  final VoidCallback onExit;
  final String? initialContentUnitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = (
      mediaItemId: mediaItemId,
      initialContentUnitId: initialContentUnitId,
    );
    final controller = ref.watch(novelReaderControllerProvider(request));
    final settings = ref.watch(readerSettingsControllerProvider(mediaItemId));
    if (controller.isLoading || settings.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (controller.hasError || settings.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('阅读器')),
        body: Center(
          child: OutlinedButton(
            onPressed: () {
              ref
                ..invalidate(novelReaderControllerProvider(request))
                ..invalidate(readerSettingsControllerProvider(mediaItemId));
            },
            child: const Text('重试'),
          ),
        ),
      );
    }
    return _ReaderScaffold(
      controller: controller.requireValue,
      settings: settings.requireValue,
      onExit: onExit,
    );
  }
}

class _ReaderScaffold extends StatefulWidget {
  const _ReaderScaffold({
    required this.controller,
    required this.settings,
    required this.onExit,
  });
  final NovelReaderController controller;
  final ReaderSettingsController settings;
  final VoidCallback onExit;

  @override
  State<_ReaderScaffold> createState() => _ReaderScaffoldState();
}

class _ReaderScaffoldState extends State<_ReaderScaffold>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  var _lastChapterIndex = -1;
  var _initialPositionRestored = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_recordScrollPosition);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_recordScrollPosition);
    unawaited(widget.controller.flushProgress());
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(widget.controller.flushProgress());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, widget.settings]),
      builder: (context, _) {
        final controller = widget.controller;
        if (controller.chapter != null &&
            controller.currentIndex != _lastChapterIndex) {
          _lastChapterIndex = controller.currentIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              if (!_initialPositionRestored) {
                _initialPositionRestored = true;
                final textLength = controller.chapter!.text.length;
                final ratio = controller.chapter!.isSemantic
                    ? controller.restoredFraction
                    : (textLength == 0
                          ? 0.0
                          : controller.restoredCharacterOffset / textLength);
                _scrollController.jumpTo(
                  _scrollController.position.maxScrollExtent * ratio,
                );
              } else {
                _scrollController.jumpTo(0);
              }
            }
          });
        }
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowLeft):
                controller.previous,
            const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                _scrollBy(-80),
            const SingleActivator(LogicalKeyboardKey.pageUp):
                controller.previous,
            const SingleActivator(LogicalKeyboardKey.arrowRight):
                controller.next,
            const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                _scrollBy(80),
            const SingleActivator(LogicalKeyboardKey.pageDown): controller.next,
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  key: const Key('reader-exit'),
                  tooltip: '返回',
                  onPressed: _exitReader,
                  icon: const Icon(Icons.arrow_back),
                ),
                title: Text(controller.chapter?.unit.title ?? '阅读器'),
                actions: [
                  Builder(
                    builder: (context) => IconButton(
                      key: const Key('reader-directory'),
                      tooltip: '目录',
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.menu),
                    ),
                  ),
                  IconButton(
                    key: const Key('reader-settings'),
                    tooltip: '阅读设置',
                    onPressed: () => _showSettings(context),
                    icon: const Icon(Icons.text_fields),
                  ),
                ],
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

  void _scrollBy(double delta) {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + delta).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
  }

  Future<void> _exitReader() async {
    await widget.controller.flushProgress();
    if (mounted) widget.onExit();
  }

  void _recordScrollPosition() {
    if (!_scrollController.hasClients || widget.controller.chapter == null) {
      return;
    }
    final maximum = _scrollController.position.maxScrollExtent;
    final fraction = maximum <= 0
        ? 0.0
        : (_scrollController.offset / maximum).clamp(0.0, 1.0);
    final characterOffset = (widget.controller.chapter!.text.length * fraction)
        .round();
    widget.controller.updatePosition(
      characterOffset: characterOffset,
      fraction: fraction,
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
    final palette = _palette(
      widget.settings.preference.themeKey,
      Theme.of(context).brightness,
    );
    return ColoredBox(
      key: const Key('reader-surface'),
      color: palette.background,
      child: Stack(
        children: [
          SelectionArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 80),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: controller.chapter!.isSemantic
                      ? _SemanticChapter(
                          chapter: controller.chapter!,
                          fontSize: widget.settings.preference.fontSize,
                          lineHeight: widget.settings.preference.lineHeight,
                          foreground: palette.foreground,
                        )
                      : Text(
                          controller.chapter!.text,
                          style: TextStyle(
                            fontSize: widget.settings.preference.fontSize,
                            height: widget.settings.preference.lineHeight,
                            color: palette.foreground,
                          ),
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
      ),
    );
  }

  Future<void> _showSettings(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ReaderSettingsSheet(controller: widget.settings),
    );
  }
}

class _SemanticChapter extends StatelessWidget {
  const _SemanticChapter({
    required this.chapter,
    required this.fontSize,
    required this.lineHeight,
    required this.foreground,
  });

  final ReaderChapter chapter;
  final double fontSize;
  final double lineHeight;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [for (final block in chapter.blocks) _buildBlock(context, block)],
  );

  Widget _buildBlock(BuildContext context, ReaderBlock block) {
    if (block.kind == ReaderBlockKind.divider) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Divider(),
      );
    }
    if (block.kind == ReaderBlockKind.image) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Semantics(
          label: block.altText ?? '插图',
          image: true,
          child: Image.file(
            File(block.imagePath!),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('插图无法显示'),
              ),
            ),
          ),
        ),
      );
    }
    final baseStyle = TextStyle(
      fontSize: block.kind == ReaderBlockKind.heading
          ? fontSize + (7 - (block.headingLevel ?? 2))
          : fontSize,
      height: lineHeight,
      color: foreground,
      fontWeight: block.kind == ReaderBlockKind.heading
          ? FontWeight.w600
          : null,
    );
    final prefix = switch (block.kind) {
      ReaderBlockKind.listItem => block.ordered == true ? '•  ' : '•  ',
      ReaderBlockKind.quote => '│  ',
      _ => '',
    };
    return Padding(
      padding: EdgeInsets.only(
        left: block.kind == ReaderBlockKind.listItem
            ? 16.0 * (block.listDepth ?? 1)
            : 0,
        bottom: block.kind == ReaderBlockKind.heading ? 16 : 12,
      ),
      child: Text.rich(
        _styledSpan(prefix, block, baseStyle),
        key: ValueKey('epub-block-${chapter.blocks.indexOf(block)}'),
      ),
    );
  }

  TextSpan _styledSpan(String prefix, ReaderBlock block, TextStyle baseStyle) {
    final text = block.text ?? '';
    if (block.styleSpans.isEmpty) {
      return TextSpan(text: '$prefix$text', style: baseStyle);
    }
    final children = <InlineSpan>[];
    if (prefix.isNotEmpty) children.add(TextSpan(text: prefix));
    var cursor = 0;
    final spans = [...block.styleSpans]
      ..sort((left, right) => left.start.compareTo(right.start));
    for (final span in spans) {
      if (span.start < cursor) continue;
      if (span.start > cursor) {
        children.add(TextSpan(text: text.substring(cursor, span.start)));
      }
      children.add(
        TextSpan(
          text: text.substring(span.start, span.end),
          style: TextStyle(
            fontWeight: span.bold ? FontWeight.bold : null,
            fontStyle: span.italic ? FontStyle.italic : null,
          ),
        ),
      );
      cursor = span.end;
    }
    if (cursor < text.length) {
      children.add(TextSpan(text: text.substring(cursor)));
    }
    return TextSpan(style: baseStyle, children: children);
  }
}

class _ReaderSettingsSheet extends StatelessWidget {
  const _ReaderSettingsSheet({required this.controller});
  final ReaderSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('阅读设置', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              Text('字号 ${controller.preference.fontSize.round()}'),
              Slider(
                key: const Key('font-size-slider'),
                min: 12,
                max: 36,
                divisions: 24,
                value: controller.preference.fontSize,
                onChanged: controller.setFontSize,
              ),
              Text('行距 ${controller.preference.lineHeight.toStringAsFixed(1)}'),
              Slider(
                key: const Key('line-height-slider'),
                min: 1.2,
                max: 2.4,
                divisions: 12,
                value: controller.preference.lineHeight,
                onChanged: controller.setLineHeight,
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'system', label: Text('跟随系统')),
                  ButtonSegment(value: 'light', label: Text('浅色')),
                  ButtonSegment(value: 'dark', label: Text('深色')),
                  ButtonSegment(value: 'sepia', label: Text('护眼')),
                ],
                selected: {controller.preference.themeKey},
                onSelectionChanged: (values) =>
                    controller.setTheme(values.single),
              ),
              if (controller.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(controller.errorMessage!),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: controller.resetToInherited,
                child: const Text('恢复默认'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

({Color background, Color foreground}) _palette(
  String themeKey,
  Brightness systemBrightness,
) {
  final resolved = themeKey == 'system'
      ? (systemBrightness == Brightness.dark ? 'dark' : 'light')
      : themeKey;
  return switch (resolved) {
    'dark' => (
      background: const Color(0xff151515),
      foreground: const Color(0xffe6e1da),
    ),
    'sepia' => (
      background: const Color(0xfff3ead3),
      foreground: const Color(0xff463c2d),
    ),
    _ => (
      background: const Color(0xfffaf8f4),
      foreground: const Color(0xff24211d),
    ),
  };
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
