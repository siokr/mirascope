import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/manga_providers.dart';
import '../application/manga_reading_state.dart';
import '../application/manga_page_loader.dart';
import '../domain/manga_page.dart';
import '../domain/manga_reader_book.dart';
import '../domain/manga_reader_preference.dart';

class MangaReaderPage extends ConsumerWidget {
  const MangaReaderPage({
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
    final reading = ref.watch(mangaReadingStateProvider(request));
    return reading.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: const Text('漫画阅读器')),
        body: const Center(child: Text('无法打开漫画')),
      ),
      data: (value) {
        final loader = ref.watch(mangaPageLoaderProvider(mediaItemId));
        return loader.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, _) => Scaffold(
            appBar: AppBar(title: const Text('漫画阅读器')),
            body: const Center(child: Text('无法准备页面缓存')),
          ),
          data: (pageLoader) => _Reader(
            book: value.book,
            readingState: value,
            loader: pageLoader,
            onExit: onExit,
          ),
        );
      },
    );
  }
}

class _Reader extends StatefulWidget {
  const _Reader({
    required this.book,
    required this.loader,
    required this.readingState,
    required this.onExit,
  });
  final MangaReaderBook book;
  final MangaPageLoader loader;
  final MangaReadingState readingState;
  final VoidCallback onExit;

  @override
  State<_Reader> createState() => _ReaderState();
}

class _ReaderState extends State<_Reader> with WidgetsBindingObserver {
  late int _currentIndex;
  var _mode = MangaReadingMode.vertical;
  var _direction = PageTurnDirection.leftToRight;
  late PageController _pageController;
  final ScrollController _scrollController = ScrollController();
  final _loads = <String, Future<Uint8List>>{};
  final _failedPages = <String>{};
  var _memoryPressure = false;
  late final List<GlobalKey> _pageKeys;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.readingState.currentPageIndex;
    _mode = widget.readingState.mode;
    _direction = widget.readingState.direction;
    _pageKeys = List.generate(widget.book.pages.length, (_) => GlobalKey());
    _pageController = PageController(
      initialPage: _mode == MangaReadingMode.doublePage
          ? _spreadIndex(_currentIndex)
          : _currentIndex,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreVertical());
    unawaited(widget.loader.preloadAround(widget.book.pages, _currentIndex));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.loader.cancelPreload();
    unawaited(widget.readingState.flushProgress());
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(widget.readingState.flushProgress());
    }
  }

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.escape): () =>
          unawaited(_exit()),
      const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
          _step(_direction == PageTurnDirection.leftToRight ? -1 : 1),
      const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
          _step(_direction == PageTurnDirection.leftToRight ? 1 : -1),
      const SingleActivator(LogicalKeyboardKey.arrowUp): () => _scroll(-160),
      const SingleActivator(LogicalKeyboardKey.arrowDown): () => _scroll(160),
    },
    child: Focus(
      autofocus: true,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            key: const Key('manga-reader-exit'),
            tooltip: '返回',
            onPressed: _exit,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(widget.book.mediaItem.title),
          actions: [
            IconButton(
              key: const Key('manga-reader-directory'),
              tooltip: '目录',
              onPressed: _showDirectory,
              icon: const Icon(Icons.menu_book_outlined),
            ),
            IconButton(
              key: const Key('manga-reader-settings'),
              tooltip: '阅读设置',
              onPressed: _showSettings,
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
        body: Column(
          children: [
            if (_currentChapterFailed) _chapterFailureBanner(),
            if (_memoryPressure)
              const MaterialBanner(
                content: Text('内存不足，已停止预加载；可重试当前页面。'),
                actions: [SizedBox.shrink()],
              ),
            Expanded(
              child: _mode == MangaReadingMode.vertical
                  ? _vertical()
                  : _horizontal(
                      doublePage: _mode == MangaReadingMode.doublePage,
                    ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${_currentIndex + 1} / ${widget.book.pages.length}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _vertical() => NotificationListener<UserScrollNotification>(
    onNotification: (_) {
      _recordVerticalPage();
      return false;
    },
    child: ListView.builder(
      key: const Key('manga-vertical-reader'),
      controller: _scrollController,
      itemCount: widget.book.pages.length,
      itemBuilder: (context, index) => KeyedSubtree(
        key: _pageKeys[index],
        child: _PageImage(
          key: ValueKey('manga-page-$index'),
          load: _load(widget.book.pages[index]),
          onError: (error) => _recordFailure(widget.book.pages[index], error),
          onRetry: () => _retryPage(widget.book.pages[index]),
        ),
      ),
    ),
  );

  void _recordVerticalPage() {
    var closest = _currentIndex;
    var closestDistance = double.infinity;
    var fraction = 0.0;
    for (var index = 0; index < _pageKeys.length; index++) {
      final box = _pageKeys[index].currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached) continue;
      final distance = box.localToGlobal(Offset.zero).dy.abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closest = index;
        fraction = (-box.localToGlobal(Offset.zero).dy / box.size.height).clamp(
          0.0,
          1.0,
        );
      }
    }
    if (mounted) {
      _setCurrentPage(closest, fraction: fraction);
    }
  }

  Widget _horizontal({required bool doublePage}) => PageView.builder(
    key: const Key('manga-horizontal-reader'),
    controller: _pageController,
    reverse: _direction == PageTurnDirection.rightToLeft,
    itemCount: doublePage ? _spreadCount : widget.book.pages.length,
    onPageChanged: (index) =>
        _setCurrentPage(doublePage ? _spreadStart(index) : index),
    itemBuilder: (context, index) => InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: doublePage ? _spread(index) : _horizontalPage(index),
    ),
  );

  int get _spreadCount => 1 + ((widget.book.pages.length - 1) / 2).ceil();
  int _spreadIndex(int pageIndex) => pageIndex == 0 ? 0 : (pageIndex + 1) ~/ 2;
  int _spreadStart(int spreadIndex) =>
      spreadIndex == 0 ? 0 : spreadIndex * 2 - 1;

  Widget _horizontalPage(int index) =>
      Center(child: _pageImage(widget.book.pages[index]));

  Widget _spread(int spreadIndex) {
    final firstIndex = _spreadStart(spreadIndex);
    final indexes = [
      firstIndex,
      if (firstIndex + 1 < widget.book.pages.length) firstIndex + 1,
    ];
    if (_direction == PageTurnDirection.rightToLeft) {
      indexes.setAll(0, indexes.reversed);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final index in indexes)
          Expanded(child: Center(child: _pageImage(widget.book.pages[index]))),
      ],
    );
  }

  Widget _pageImage(MangaPage page) => _PageImage(
    key: Key('manga-page-image-${page.id}'),
    load: _load(page),
    onError: (error) => _recordFailure(page, error),
    onRetry: () => _retryPage(page),
  );

  Future<Uint8List> _load(MangaPage page) =>
      _loads.putIfAbsent(page.id, () => widget.loader.load(page));

  void _recordFailure(MangaPage page, Object error) {
    if (!mounted || _failedPages.contains(page.id)) return;
    setState(() {
      _failedPages.add(page.id);
      if (error is OutOfMemoryError) {
        _memoryPressure = true;
        widget.loader.cancelPreload();
      }
    });
  }

  void _retryPage(MangaPage page) => setState(() {
    _loads[page.id] = widget.loader.load(page);
    _failedPages.remove(page.id);
  });

  bool get _currentChapterFailed {
    final chapterId = widget.book.pages[_currentIndex].contentUnitId;
    final pages = widget.book.pages.where(
      (page) => page.contentUnitId == chapterId,
    );
    return pages.isNotEmpty &&
        pages.every((page) => _failedPages.contains(page.id));
  }

  Widget _chapterFailureBanner() => MaterialBanner(
    content: const Text('本章所有页面均无法读取，请检查源文件或重试。'),
    actions: [
      TextButton(onPressed: _retryCurrentChapter, child: const Text('重试本章')),
      TextButton(onPressed: _showDirectory, child: const Text('返回目录')),
    ],
  );

  void _retryCurrentChapter() {
    final chapterId = widget.book.pages[_currentIndex].contentUnitId;
    setState(() {
      for (final page in widget.book.pages.where(
        (page) => page.contentUnitId == chapterId,
      )) {
        _loads[page.id] = widget.loader.load(page);
        _failedPages.remove(page.id);
      }
    });
  }

  void _step(int delta) {
    if (_mode == MangaReadingMode.vertical) return;
    final current = _mode == MangaReadingMode.doublePage
        ? _spreadIndex(_currentIndex)
        : _currentIndex;
    final maximum = _mode == MangaReadingMode.doublePage
        ? _spreadCount - 1
        : widget.book.pages.length - 1;
    final target = (current + delta).clamp(0, maximum);
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  void _scroll(double delta) {
    if (_mode != MangaReadingMode.vertical || !_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      (_scrollController.offset + delta).clamp(
        0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
  }

  void _setMode(MangaReadingMode mode) {
    if (_mode == mode) return;
    unawaited(widget.readingState.flushProgress());
    setState(() {
      _mode = mode;
      if (mode != MangaReadingMode.vertical) {
        _pageController.dispose();
        _pageController = PageController(
          initialPage: mode == MangaReadingMode.doublePage
              ? _spreadIndex(_currentIndex)
              : _currentIndex,
        );
      }
    });
    unawaited(widget.readingState.setPreference(_mode, _direction));
    if (mode == MangaReadingMode.vertical) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _restoreVertical());
    }
  }

  void _setCurrentPage(int index, {double fraction = 0}) {
    final changed = _currentIndex != index;
    if (changed) {
      setState(() => _currentIndex = index);
    }
    widget.readingState.updatePage(index, fraction: fraction);
    if (changed) {
      unawaited(widget.loader.preloadAround(widget.book.pages, index));
      unawaited(widget.readingState.flushProgress());
    }
  }

  Future<void> _exit() async {
    await widget.readingState.flushProgress();
    if (mounted) widget.onExit();
  }

  void _restoreVertical() {
    if (!_scrollController.hasClients) return;
    final maximum = _scrollController.position.maxScrollExtent;
    final target = widget.book.pages.length <= 1
        ? 0.0
        : maximum * _currentIndex / (widget.book.pages.length - 1);
    _scrollController.jumpTo(target.clamp(0, maximum));
  }

  Future<void> _showSettings() => showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<MangaReadingMode>(
              segments: const [
                ButtonSegment(
                  value: MangaReadingMode.vertical,
                  label: Text('纵向连续'),
                ),
                ButtonSegment(
                  value: MangaReadingMode.horizontal,
                  label: Text('横向单页'),
                ),
                ButtonSegment(
                  value: MangaReadingMode.doublePage,
                  label: Text('横向双页'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (values) {
                Navigator.pop(context);
                _setMode(values.single);
              },
            ),
            const SizedBox(height: 16),
            SegmentedButton<PageTurnDirection>(
              segments: const [
                ButtonSegment(
                  value: PageTurnDirection.leftToRight,
                  label: Text('从左到右'),
                ),
                ButtonSegment(
                  value: PageTurnDirection.rightToLeft,
                  label: Text('从右到左'),
                ),
              ],
              selected: {_direction},
              onSelectionChanged: (values) {
                setState(() => _direction = values.single);
                unawaited(widget.readingState.setPreference(_mode, _direction));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _showDirectory() => showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final chapter in widget.book.chapters)
            ListTile(
              title: Text(chapter.unit.title),
              subtitle: Text('${chapter.pages.length} 页'),
              onTap: () {
                Navigator.pop(context);
                final index = widget.book.pages.indexWhere(
                  (page) => page.contentUnitId == chapter.unit.id,
                );
                if (index >= 0) {
                  _setCurrentPage(index);
                  if (_mode != MangaReadingMode.vertical) {
                    _pageController.jumpToPage(
                      _mode == MangaReadingMode.doublePage
                          ? _spreadIndex(index)
                          : index,
                    );
                  } else {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _restoreVertical(),
                    );
                  }
                }
              },
            ),
        ],
      ),
    ),
  );
}

class _PageImage extends StatefulWidget {
  const _PageImage({
    required this.load,
    required this.onError,
    required this.onRetry,
    super.key,
  });
  final Future<Uint8List> load;
  final ValueChanged<Object> onError;
  final VoidCallback onRetry;
  @override
  State<_PageImage> createState() => _PageImageState();
}

class _PageImageState extends State<_PageImage> {
  Object? _reportedError;

  @override
  void didUpdateWidget(covariant _PageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.load != widget.load) _reportedError = null;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: widget.load,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        final error = snapshot.error!;
        if (!identical(_reportedError, error)) {
          _reportedError = error;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.onError(error),
          );
        }
        return SizedBox(
          height: 320,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('此页无法显示'),
                TextButton(
                  onPressed: widget.onRetry,
                  child: const Text('重试当前页'),
                ),
              ],
            ),
          ),
        );
      }
      if (!snapshot.hasData) {
        return const SizedBox(
          height: 320,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return Image.memory(
        snapshot.data!,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) =>
            const SizedBox(height: 320, child: Center(child: Text('此页无法显示'))),
      );
    },
  );
}
