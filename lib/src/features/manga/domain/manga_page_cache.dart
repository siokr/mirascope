import 'dart:typed_data';

final class MangaPageCacheKey {
  const MangaPageCacheKey({
    required this.mediaItemId,
    required this.contentHash,
    required this.byteLength,
  });
  final String mediaItemId;
  final String contentHash;
  final int byteLength;
  String get stableValue => '$mediaItemId\u0000$contentHash\u0000$byteLength';
}

abstract interface class MangaPageCache {
  Future<Uint8List?> get(MangaPageCacheKey key);
  Future<void> put(MangaPageCacheKey key, Uint8List bytes);
  Future<void> clear();
}

final class MangaPageCacheBudget {
  const MangaPageCacheBudget({
    this.maximumMemoryBytes = 64 * 1024 * 1024,
    this.maximumDiskBytes = 512 * 1024 * 1024,
  });
  final int maximumMemoryBytes;
  final int maximumDiskBytes;
}
