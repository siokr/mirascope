import 'dart:io';

import '../../importing/domain/derived_manga_store.dart';
import '../domain/custom_cover_store.dart';

final class DartIoCustomCoverStore implements CustomCoverStore {
  const DartIoCustomCoverStore(this.rootDirectory, this.encoder);

  final Directory rootDirectory;
  final MangaThumbnailEncoder encoder;

  @override
  Future<String> replaceFromFile({
    required String mediaItemId,
    required String sourcePath,
  }) async {
    _validateMediaId(mediaItemId);
    final encoded = await encoder.encode(await File(sourcePath).readAsBytes());
    final directory = Directory(
      '${rootDirectory.path}${Platform.pathSeparator}$mediaItemId',
    );
    await directory.create(recursive: true);
    final target = File('${directory.path}${Platform.pathSeparator}cover.png');
    final temporary = File('${target.path}.tmp');
    try {
      await temporary.writeAsBytes(encoded, flush: true);
      if (await target.exists()) await target.delete();
      await temporary.rename(target.path);
    } on Object {
      if (await temporary.exists()) await temporary.delete();
      rethrow;
    }
    return 'custom/$mediaItemId/cover.png';
  }

  @override
  Future<File?> resolve(String coverRef) async {
    final match = RegExp(
      r'^custom/([A-Za-z0-9_-]+)/cover\.png$',
    ).firstMatch(coverRef);
    if (match == null) return null;
    final file = File(
      '${rootDirectory.path}${Platform.pathSeparator}${match.group(1)}'
      '${Platform.pathSeparator}cover.png',
    );
    return await file.exists() ? file : null;
  }

  @override
  Future<void> remove(String mediaItemId) async {
    _validateMediaId(mediaItemId);
    final directory = Directory(
      '${rootDirectory.path}${Platform.pathSeparator}$mediaItemId',
    );
    if (await directory.exists()) await directory.delete(recursive: true);
  }

  void _validateMediaId(String mediaItemId) {
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(mediaItemId)) {
      throw ArgumentError.value(mediaItemId, 'mediaItemId', 'Unsafe media ID');
    }
  }
}
