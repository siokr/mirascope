import 'dart:typed_data';

import '../../library/domain/media_item.dart';
import '../../novel/domain/content_unit.dart';
import 'manga_page.dart';

final class MangaReaderChapter {
  MangaReaderChapter({required this.unit, required List<MangaPage> pages})
    : pages = List.unmodifiable(pages);
  final ContentUnit unit;
  final List<MangaPage> pages;
}

final class MangaReaderBook {
  MangaReaderBook({
    required this.mediaItem,
    required List<MangaReaderChapter> chapters,
  }) : chapters = List.unmodifiable(chapters),
       pages = List.unmodifiable([
         for (final chapter in chapters) ...chapter.pages,
       ]);
  final MediaItem mediaItem;
  final List<MangaReaderChapter> chapters;
  final List<MangaPage> pages;
}

abstract interface class MangaReaderRepository {
  Future<MangaReaderBook?> loadBook(String mediaItemId);
  Future<Uint8List> readPage(String mediaItemId, MangaPage page);
}
