import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/manga/data/dart_io_manga_page_cache.dart';
import 'package:mirascope/src/features/manga/domain/manga_page_cache.dart';

void main() {
  late Directory root;
  setUp(
    () async => root = await Directory.systemTemp.createTemp('manga-cache-'),
  );
  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('persists valid bytes and a new cache instance can read them', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final key = _key('media', bytes);
    await DartIoMangaPageCache(root).put(key, bytes);
    expect(await DartIoMangaPageCache(root).get(key), bytes);
  });

  test('corrupt disk entry becomes a safe cache miss', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final key = _key('media', bytes);
    await DartIoMangaPageCache(root).put(key, bytes);
    final file = await root
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .single;
    await file.writeAsBytes([9, 9, 9]);
    expect(await DartIoMangaPageCache(root).get(key), isNull);
    expect(await file.exists(), isFalse);
  });

  test(
    'disk budget evicts oldest entries and clear removes all layers',
    () async {
      final cache = DartIoMangaPageCache(
        root,
        budget: const MangaPageCacheBudget(
          maximumMemoryBytes: 3,
          maximumDiskBytes: 5,
        ),
      );
      await cache.put(
        _key('one', Uint8List.fromList([1, 1, 1])),
        Uint8List.fromList([1, 1, 1]),
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await cache.put(
        _key('two', Uint8List.fromList([2, 2, 2])),
        Uint8List.fromList([2, 2, 2]),
      );
      expect(await root.list().where((entity) => entity is File).length, 1);
      await cache.clear();
      expect(await root.exists(), isFalse);
    },
  );
}

MangaPageCacheKey _key(String media, Uint8List bytes) => MangaPageCacheKey(
  mediaItemId: media,
  contentHash: 'sha256:${sha256.convert(bytes)}',
  byteLength: bytes.length,
);
