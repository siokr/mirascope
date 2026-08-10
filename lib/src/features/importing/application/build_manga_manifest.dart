import 'package:crypto/crypto.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/manga_manifest.dart';
import 'natural_path_comparator.dart';

final class BuildMangaManifest {
  const BuildMangaManifest(this.imageDecoder);

  final MangaImageDecoder imageDecoder;

  static const _extensions = {'jpg', 'jpeg', 'png', 'webp'};

  Future<MangaManifest> call(Iterable<MangaSourceImage> sourceImages) async {
    final candidates = sourceImages.toList()
      ..sort((a, b) => compareNaturalPaths(a.path, b.path));
    final chapters = <String, List<MangaManifestPage>>{};
    var invalidImages = 0;
    var ignoredFiles = 0;

    for (final candidate in candidates) {
      final path = candidate.path.replaceAll('\\', '/');
      if (_isHidden(path) || !_isSupported(path)) {
        ignoredFiles++;
        continue;
      }
      final bytes = await candidate.readBytes();
      try {
        final metadata = await imageDecoder.decode(bytes);
        final chapter = _chapterTitle(path);
        (chapters[chapter] ??= []).add(
          MangaManifestPage(
            sourcePath: path,
            contentHash: 'sha256:${sha256.convert(bytes)}',
            imageType: metadata.type,
            byteLength: bytes.length,
            pixelWidth: metadata.width,
            pixelHeight: metadata.height,
          ),
        );
      } on Object {
        invalidImages++;
      }
    }

    if (chapters.isEmpty) {
      throw AppFailure.fromCode(AppErrorCode.mangaNoImages);
    }
    final titles = chapters.keys.toList()..sort(compareNaturalPaths);
    return MangaManifest(
      chapters: [
        for (final title in titles)
          MangaManifestChapter(title: title, pages: chapters[title]!),
      ],
      invalidImageCount: invalidImages,
      ignoredFileCount: ignoredFiles,
    );
  }

  static bool _isSupported(String path) {
    final dot = path.lastIndexOf('.');
    return dot >= 0 &&
        _extensions.contains(path.substring(dot + 1).toLowerCase());
  }

  static bool _isHidden(String path) =>
      path.split('/').any((part) => part.startsWith('.') && part.length > 1);

  static String _chapterTitle(String path) {
    final slash = path.lastIndexOf('/');
    return slash < 0 ? '正文' : path.substring(0, slash);
  }
}
