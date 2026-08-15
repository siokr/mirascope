import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/manga_providers.dart';
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
    final book = ref.watch(mangaReaderBookProvider(mediaItemId));
    return book.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: const Text('漫画阅读器')),
        body: const Center(child: Text('无法打开漫画')),
      ),
      data: (value) => value == null || value.pages.isEmpty
          ? Scaffold(
              appBar: AppBar(title: const Text('漫画阅读器')),
              body: const Center(child: Text('没有可阅读的页面')),
            )
          : _Reader(
              book: value,
              repository: ref.watch(mangaReaderRepositoryProvider),
              mediaItemId: mediaItemId,
              initialContentUnitId: initialContentUnitId,
              onExit: onExit,
            ),
    );
  }
}

class _Reader extends StatefulWidget {
  const _Reader({
    required this.book,
    required this.repository,
    required this.mediaItemId,
    required this.onExit,
    this.initialContentUnitId,
  });
  final MangaReaderBook book;
  final MangaReaderRepository repository;
  final String mediaItemId;
  final String? initialContentUnitId;
  final VoidCallback onExit;

  @override
  State<_Reader> createState() => _ReaderState();
}

class _ReaderState extends State<_Reader> {
  late int _currentIndex;
  var _mode = MangaReadingMode.vertical;
  var _direction = PageTurnDirection.leftToRight;
  late PageController _pageController;
  final ScrollController _scrollController = ScrollController();
  final _loads = <String, Future<Uint8List>>{};
  late final List<GlobalKey> _pageKeys;

  @override
  void initState() {
    super.initState();
    _currentIndex = _initialIndex();
    _pageKeys = List.generate(widget.book.pages.length, (_) => GlobalKey());
    _pageController = PageController(initialPage: _currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreVertical());
  }

  int _initialIndex() {
    final chapterId = widget.initialContentUnitId;
    if (chapterId == null) return 0;
    final index = widget.book.pages.indexWhere(
      (page) => page.contentUnitId == chapterId,
    );
    return index < 0 ? 0 : index;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.escape): widget.onExit,
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
            onPressed: widget.onExit,
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
        body: _mode == MangaReadingMode.vertical ? _vertical() : _horizontal(),
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
        ),
      ),
    ),
  );

  void _recordVerticalPage() {
    var closest = _currentIndex;
    var closestDistance = double.infinity;
    for (var index = 0; index < _pageKeys.length; index++) {
      final box = _pageKeys[index].currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached) continue;
      final distance = box.localToGlobal(Offset.zero).dy.abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closest = index;
      }
    }
    if (closest != _currentIndex && mounted) {
      setState(() => _currentIndex = closest);
    }
  }

  Widget _horizontal() => PageView.builder(
    key: const Key('manga-horizontal-reader'),
    controller: _pageController,
    reverse: _direction == PageTurnDirection.rightToLeft,
    itemCount: widget.book.pages.length,
    onPageChanged: (index) => setState(() => _currentIndex = index),
    itemBuilder: (context, index) => InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(child: _PageImage(load: _load(widget.book.pages[index]))),
    ),
  );

  Future<Uint8List> _load(MangaPage page) => _loads.putIfAbsent(
    page.id,
    () => widget.repository.readPage(widget.mediaItemId, page),
  );

  void _step(int delta) {
    if (_mode != MangaReadingMode.horizontal) return;
    final target = (_currentIndex + delta).clamp(
      0,
      widget.book.pages.length - 1,
    );
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
    setState(() {
      _mode = mode;
      if (mode == MangaReadingMode.horizontal) {
        _pageController.dispose();
        _pageController = PageController(initialPage: _currentIndex);
      }
    });
    if (mode == MangaReadingMode.vertical) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _restoreVertical());
    }
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
                  setState(() => _currentIndex = index);
                  if (_mode == MangaReadingMode.horizontal) {
                    _pageController.jumpToPage(index);
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
  const _PageImage({required this.load, super.key});
  final Future<Uint8List> load;
  @override
  State<_PageImage> createState() => _PageImageState();
}

class _PageImageState extends State<_PageImage> {
  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: widget.load,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const SizedBox(
          height: 320,
          child: Center(child: Text('此页无法显示')),
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
