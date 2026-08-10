import 'dart:io';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../application/build_manga_manifest.dart';
import '../domain/manga_manifest.dart';
import '../domain/manga_source.dart';
import 'dart_io_manga_archive_container.dart';

final class DartIoMangaManifestScanner {
  const DartIoMangaManifestScanner(this.imageDecoder);

  final MangaImageDecoder imageDecoder;

  Future<MangaManifest> scan(MangaSourceSelection selection) async {
    return switch (selection.kind) {
      MangaSourceKind.directory => _scanDirectory(selection.path),
      MangaSourceKind.archive => _scanArchive(selection.path),
    };
  }

  Future<MangaManifest> _scanDirectory(String sourcePath) async {
    final root = Directory(sourcePath);
    if (await root.stat().then((stat) => stat.type) !=
        FileSystemEntityType.directory) {
      throw AppFailure.fromCode(AppErrorCode.fileNotFound);
    }
    final separator = root.path.endsWith(Platform.pathSeparator)
        ? ''
        : Platform.pathSeparator;
    final prefix = '${root.path}$separator';
    final images = <MangaSourceImage>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.startsWith(prefix)) continue;
      final path = entity.path
          .substring(prefix.length)
          .replaceAll(Platform.pathSeparator, '/');
      images.add(MangaSourceImage(path: path, readBytes: entity.readAsBytes));
    }
    return BuildMangaManifest(imageDecoder)(images);
  }

  Future<MangaManifest> _scanArchive(String sourcePath) async {
    final container = await DartIoMangaArchiveContainer.open(sourcePath);
    try {
      return await BuildMangaManifest(imageDecoder)([
        for (final entry in container.entries)
          MangaSourceImage(
            path: entry.path,
            readBytes: () => container.readBytes(entry.path),
          ),
      ]);
    } finally {
      await container.close();
    }
  }
}
