import 'dart:typed_data';

final class EpubContainerEntry {
  const EpubContainerEntry({
    required this.path,
    required this.uncompressedSize,
    required this.compressedSize,
  });

  final String path;
  final int uncompressedSize;
  final int compressedSize;
}

abstract interface class EpubContainer {
  List<EpubContainerEntry> get entries;

  bool contains(String path);

  Future<Uint8List> readBytes(String path);

  Future<void> close();
}

final class EpubContainerBudget {
  const EpubContainerBudget({
    this.maximumEntryCount = 10000,
    this.maximumEntrySize = 32 * 1024 * 1024,
    this.maximumTotalSize = 512 * 1024 * 1024,
    this.maximumCompressionRatio = 200,
  });

  final int maximumEntryCount;
  final int maximumEntrySize;
  final int maximumTotalSize;
  final int maximumCompressionRatio;
}
