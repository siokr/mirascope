import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/importing/data/dart_io_derived_manga_store.dart';
import 'package:mirascope/src/features/importing/domain/derived_manga_store.dart';
import 'package:mirascope/src/features/importing/domain/manga_manifest.dart';

void main() {
  late Directory root;
  setUp(
    () async => root = await Directory.systemTemp.createTemp('manga-derived-'),
  );
  tearDown(() => root.delete(recursive: true));

  test('stages, promotes and removes only the derived media directory', () async {
    final store = DartIoDerivedMangaStore(root, const _Encoder());
    final staged = await store.stage(
      mediaItemId: 'media-1',
      manifest: _emptyManifest,
      coverBytes: Uint8List.fromList([1]),
    );
    expect(
      await File(
        '${staged.temporaryToken}${Platform.pathSeparator}cover.png',
      ).readAsBytes(),
      [9, 8],
    );
    expect(
      await File(
        '${staged.temporaryToken}${Platform.pathSeparator}manifest.json',
      ).exists(),
      isTrue,
    );
    await store.promote(staged);
    expect(
      await Directory(
        '${root.path}${Platform.pathSeparator}content${Platform.pathSeparator}media-1',
      ).exists(),
      isTrue,
    );
    await store.removeCommittedRef('manga/media-1/chapters/0');
    expect(
      await Directory(
        '${root.path}${Platform.pathSeparator}content${Platform.pathSeparator}media-1',
      ).exists(),
      isFalse,
    );
  });

  test('rejects unsafe derived cleanup references', () async {
    final store = DartIoDerivedMangaStore(root, const _Encoder());
    await expectLater(
      store.removeCommittedRef('../media-1'),
      throwsArgumentError,
    );
  });

  test('stage failure cleans its temporary directory', () async {
    final store = DartIoDerivedMangaStore(root, const _FailingEncoder());
    await expectLater(
      store.stage(
        mediaItemId: 'media-1',
        manifest: _emptyManifest,
        coverBytes: Uint8List(1),
      ),
      throwsStateError,
    );
    expect(
      await Directory(
        '${root.path}${Platform.pathSeparator}staging${Platform.pathSeparator}media-1.tmp',
      ).exists(),
      isFalse,
    );
  });
}

final _emptyManifest = MangaManifest(
  chapters: const [],
  invalidImageCount: 0,
  ignoredFileCount: 0,
);

final class _Encoder implements MangaThumbnailEncoder {
  const _Encoder();
  @override
  Future<Uint8List> encode(Uint8List sourceBytes) async =>
      Uint8List.fromList([9, 8]);
}

final class _FailingEncoder implements MangaThumbnailEncoder {
  const _FailingEncoder();
  @override
  Future<Uint8List> encode(Uint8List sourceBytes) async =>
      throw StateError('encode');
}
