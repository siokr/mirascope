import 'package:flutter/foundation.dart';

import '../domain/novel_reader_repository.dart';
import '../domain/reader_book.dart';

final class NovelReaderController extends ChangeNotifier {
  NovelReaderController({required this.mediaItemId, required this.repository});

  final String mediaItemId;
  final NovelReaderRepository repository;

  ReaderBook? book;
  ReaderChapter? chapter;
  int currentIndex = 0;
  int? loadingIndex;
  int? retryIndex;
  String? errorMessage;
  bool initialLoading = true;

  bool get canGoPrevious => currentIndex > 0 && loadingIndex == null;
  bool get canGoNext =>
      book != null &&
      currentIndex + 1 < book!.chapters.length &&
      loadingIndex == null;

  Future<void> initialize() async {
    try {
      book = await repository.loadBook(mediaItemId);
      if (book == null || book!.chapters.isEmpty) {
        errorMessage = '无法打开这部作品';
        return;
      }
      await _load(0);
    } on Object {
      errorMessage = '无法加载阅读内容';
    } finally {
      initialLoading = false;
      notifyListeners();
    }
  }

  Future<void> previous() => select(currentIndex - 1);
  Future<void> next() => select(currentIndex + 1);

  Future<void> select(int index) async {
    final chapters = book?.chapters;
    if (chapters == null ||
        index < 0 ||
        index >= chapters.length ||
        index == currentIndex ||
        loadingIndex != null) {
      return;
    }
    await _load(index);
  }

  Future<void> retry() async {
    if (chapter == null) {
      initialLoading = true;
      errorMessage = null;
      notifyListeners();
      await initialize();
    } else {
      await _load(retryIndex ?? currentIndex);
    }
  }

  Future<void> _load(int index) async {
    loadingIndex = index;
    errorMessage = null;
    notifyListeners();
    try {
      final loaded = await repository.readChapter(book!.chapters[index]);
      chapter = loaded;
      currentIndex = index;
      retryIndex = null;
    } on Object {
      retryIndex = index;
      errorMessage = '无法读取所选章节';
    } finally {
      loadingIndex = null;
      notifyListeners();
    }
  }
}
