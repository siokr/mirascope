import 'dart:typed_data';

final class MangaArchiveEntry {
  const MangaArchiveEntry({
    required this.path,
    required this.uncompressedSize,
    required this.compressedSize,
  });

  final String path;
  final int uncompressedSize;
  final int compressedSize;
}

abstract interface class MangaArchiveContainer {
  List<MangaArchiveEntry> get entries;

  bool contains(String path);

  Future<Uint8List> readBytes(String path);

  Future<void> close();
}

final class MangaArchiveBudget {
  const MangaArchiveBudget({
    this.maximumArchiveSize = 2 * 1024 * 1024 * 1024,
    this.maximumEntryCount = 20000,
    this.maximumEntrySize = 64 * 1024 * 1024,
    this.maximumTotalSize = 2 * 1024 * 1024 * 1024,
    this.maximumCompressionRatio = 200,
  });

  final int maximumArchiveSize;
  final int maximumEntryCount;
  final int maximumEntrySize;
  final int maximumTotalSize;
  final int maximumCompressionRatio;
}
