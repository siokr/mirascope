import 'dart:typed_data';

import '../../manga/domain/manga_page.dart';

final class MangaImageMetadata {
  const MangaImageMetadata({
    required this.type,
    required this.width,
    required this.height,
  });

  final MangaImageType type;
  final int width;
  final int height;
}

abstract interface class MangaImageDecoder {
  Future<MangaImageMetadata> decode(Uint8List bytes);
}

final class MangaSourceImage {
  const MangaSourceImage({required this.path, required this.readBytes});

  final String path;
  final Future<Uint8List> Function() readBytes;
}

final class MangaManifestPage {
  const MangaManifestPage({
    required this.sourcePath,
    required this.contentHash,
    required this.imageType,
    required this.byteLength,
    required this.pixelWidth,
    required this.pixelHeight,
  });

  final String sourcePath;
  final String contentHash;
  final MangaImageType imageType;
  final int byteLength;
  final int pixelWidth;
  final int pixelHeight;
}

final class MangaManifestChapter {
  MangaManifestChapter({
    required this.title,
    required List<MangaManifestPage> pages,
  }) : pages = List.unmodifiable(pages);

  final String title;
  final List<MangaManifestPage> pages;
}

final class MangaManifest {
  MangaManifest({
    required List<MangaManifestChapter> chapters,
    required this.invalidImageCount,
    required this.ignoredFileCount,
  }) : chapters = List.unmodifiable(chapters);

  final List<MangaManifestChapter> chapters;
  final int invalidImageCount;
  final int ignoredFileCount;

  int get pageCount =>
      chapters.fold(0, (total, chapter) => total + chapter.pages.length);
}
