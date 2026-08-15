import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../domain/derived_manga_store.dart';
import '../domain/manga_manifest.dart';

final class DartIoDerivedMangaStore implements DerivedMangaStore {
  const DartIoDerivedMangaStore(this.rootDirectory, this.thumbnailEncoder);

  final Directory rootDirectory;
  final MangaThumbnailEncoder thumbnailEncoder;

  @override
  Future<StagedDerivedManga> stage({
    required String mediaItemId,
    required MangaManifest manifest,
    required Uint8List coverBytes,
  }) async {
    _validateMediaId(mediaItemId);
    final staging = Directory(
      '${rootDirectory.path}${Platform.pathSeparator}staging'
      '${Platform.pathSeparator}$mediaItemId.tmp',
    );
    await _deleteIfPresent(staging);
    try {
      await staging.create(recursive: true);
      final thumbnail = await thumbnailEncoder.encode(coverBytes);
      await File(
        '${staging.path}${Platform.pathSeparator}cover.png',
      ).writeAsBytes(thumbnail, flush: true);
      await File(
        '${staging.path}${Platform.pathSeparator}manifest.json',
      ).writeAsString(
        jsonEncode(<String, Object?>{
          'schema': 'manga-derived-v1',
          'chapters': [
            for (final chapter in manifest.chapters)
              <String, Object?>{
                'title': chapter.title,
                'pages': [
                  for (final page in chapter.pages)
                    <String, Object?>{
                      'sourcePath': page.sourcePath,
                      'contentHash': page.contentHash,
                      'mimeType': page.imageType.storageValue,
                      'byteLength': page.byteLength,
                      'pixelWidth': page.pixelWidth,
                      'pixelHeight': page.pixelHeight,
                    },
                ],
              },
          ],
        }),
        flush: true,
      );
      return StagedDerivedManga(
        mediaItemId: mediaItemId,
        temporaryToken: staging.path,
        coverRef: 'manga/$mediaItemId/cover.png',
      );
    } on Object {
      await _deleteIfPresent(staging);
      rethrow;
    }
  }

  @override
  Future<void> promote(StagedDerivedManga staged) async {
    _validateMediaId(staged.mediaItemId);
    final source = Directory(staged.temporaryToken);
    final target = _committed(staged.mediaItemId);
    await target.parent.create(recursive: true);
    if (await target.exists()) {
      throw StateError('Committed manga directory already exists');
    }
    await source.rename(target.path);
  }

  @override
  Future<void> discard(StagedDerivedManga staged) =>
      _deleteIfPresent(Directory(staged.temporaryToken));

  @override
  Future<void> removeCommitted(StagedDerivedManga staged) =>
      _deleteIfPresent(_committed(staged.mediaItemId));

  Directory _committed(String mediaItemId) => Directory(
    '${rootDirectory.path}${Platform.pathSeparator}content'
    '${Platform.pathSeparator}$mediaItemId',
  );

  void _validateMediaId(String mediaItemId) {
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(mediaItemId)) {
      throw ArgumentError.value(mediaItemId, 'mediaItemId', 'Unsafe media ID');
    }
  }

  Future<void> _deleteIfPresent(Directory directory) async {
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}
