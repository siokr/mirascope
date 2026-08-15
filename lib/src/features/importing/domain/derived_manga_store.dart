import 'dart:typed_data';

import 'manga_manifest.dart';

final class StagedDerivedManga {
  const StagedDerivedManga({
    required this.mediaItemId,
    required this.temporaryToken,
    required this.coverRef,
  });

  final String mediaItemId;
  final String temporaryToken;
  final String coverRef;
}

abstract interface class MangaThumbnailEncoder {
  Future<Uint8List> encode(Uint8List sourceBytes);
}

abstract interface class DerivedMangaStore {
  Future<StagedDerivedManga> stage({
    required String mediaItemId,
    required MangaManifest manifest,
    required Uint8List coverBytes,
  });

  Future<void> promote(StagedDerivedManga staged);

  Future<void> discard(StagedDerivedManga staged);

  Future<void> removeCommitted(StagedDerivedManga staged);

  Future<void> removeCommittedRef(String contentRef);
}
