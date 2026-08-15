import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/manga/application/manga_page_loader.dart';
import 'package:mirascope/src/features/manga/domain/manga_page.dart';
import 'package:mirascope/src/features/manga/domain/manga_page_cache.dart';
import 'package:mirascope/src/features/manga/domain/manga_reader_book.dart';

void main() {
  test('foreground load reads once and then hits cache', () async {
    final repository = _Repository();
    final loader = MangaPageLoader(
      mediaItemId: 'media',
      repository: repository,
      cache: _Cache(),
    );
    await loader.load(_pages[0]);
    await loader.load(_pages[0]);
    expect(repository.readIds, ['p0']);
  });

  test('preloads nearest forward and backward pages first', () async {
    final repository = _Repository();
    final loader = MangaPageLoader(
      mediaItemId: 'media',
      repository: repository,
      cache: _Cache(),
      preloadRadius: 2,
    );
    await loader.preloadAround(_pages, 2);
    expect(repository.readIds, ['p3', 'p1', 'p4', 'p0']);
  });

  test(
    'new position cancels obsolete preload before its cache write',
    () async {
      final gate = Completer<void>();
      final repository = _Repository(gate: gate);
      final cache = _Cache();
      final loader = MangaPageLoader(
        mediaItemId: 'media',
        repository: repository,
        cache: cache,
        preloadRadius: 1,
      );
      final old = loader.preloadAround(_pages, 0);
      await Future<void>.delayed(Duration.zero);
      final current = loader.preloadAround(_pages, 4);
      gate.complete();
      await Future.wait([old, current]);
      expect(cache.putIds, isNot(contains('p1')));
      expect(cache.putIds, contains('p3'));
    },
  );
}

final _pages = [for (var index = 0; index < 5; index++) _page(index)];
MangaPage _page(int index) {
  final bytes = Uint8List.fromList([index]);
  return MangaPage(
    id: 'p$index',
    contentUnitId: 'chapter',
    orderIndex: index,
    contentRef: 'p$index',
    sourceLocator: 'p$index',
    contentHash: 'sha256:${sha256.convert(bytes)}',
    imageType: MangaImageType.png,
    byteLength: 1,
  );
}

final class _Repository implements MangaReaderRepository {
  _Repository({this.gate});
  final Completer<void>? gate;
  final readIds = <String>[];
  @override
  Future<MangaReaderBook?> loadBook(String mediaItemId) async => null;
  @override
  Future<Uint8List> readPage(String mediaItemId, MangaPage page) async {
    readIds.add(page.id);
    await gate?.future;
    return Uint8List.fromList([page.orderIndex]);
  }
}

final class _Cache implements MangaPageCache {
  final values = <String, Uint8List>{};
  final putIds = <String>[];
  @override
  Future<Uint8List?> get(MangaPageCacheKey key) async =>
      values[key.stableValue];
  @override
  Future<void> put(MangaPageCacheKey key, Uint8List bytes) async {
    values[key.stableValue] = bytes;
    putIds.add('p${bytes.first}');
  }

  @override
  Future<void> clear() async => values.clear();
}
