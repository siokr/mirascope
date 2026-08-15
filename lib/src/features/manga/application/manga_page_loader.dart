import 'dart:typed_data';

import '../domain/manga_page.dart';
import '../domain/manga_page_cache.dart';
import '../domain/manga_reader_book.dart';

final class MangaPageLoader {
  MangaPageLoader({
    required this.mediaItemId,
    required this.repository,
    required this.cache,
    this.preloadRadius = 2,
  });
  final String mediaItemId;
  final MangaReaderRepository repository;
  final MangaPageCache cache;
  final int preloadRadius;
  var _generation = 0;

  Future<Uint8List> load(MangaPage page) async {
    final key = _key(page);
    final cached = await cache.get(key);
    if (cached != null) return cached;
    final bytes = await repository.readPage(mediaItemId, page);
    await cache.put(key, bytes);
    return bytes;
  }

  Future<void> preloadAround(List<MangaPage> pages, int currentIndex) async {
    final generation = ++_generation;
    final candidates = <int>[];
    for (var distance = 1; distance <= preloadRadius; distance++) {
      if (currentIndex + distance < pages.length) {
        candidates.add(currentIndex + distance);
      }
      if (currentIndex - distance >= 0) {
        candidates.add(currentIndex - distance);
      }
    }
    for (final index in candidates) {
      if (generation != _generation) return;
      final page = pages[index];
      try {
        final key = _key(page);
        if (await cache.get(key) != null) continue;
        final bytes = await repository.readPage(mediaItemId, page);
        if (generation != _generation) return;
        await cache.put(key, bytes);
      } on OutOfMemoryError {
        cancelPreload();
        return;
      } on Object {
        // Preloading is opportunistic. The foreground load owns user-visible
        // recovery, so a broken neighbouring page must not interrupt reading.
        continue;
      }
    }
  }

  void cancelPreload() => _generation++;

  MangaPageCacheKey _key(MangaPage page) => MangaPageCacheKey(
    mediaItemId: mediaItemId,
    contentHash: page.contentHash,
    byteLength: page.byteLength,
  );
}
