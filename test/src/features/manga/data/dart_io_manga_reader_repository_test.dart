import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/features/importing/data/dart_io_manga_manifest_scanner.dart';
import 'package:mirascope/src/features/importing/data/flutter_manga_image_decoder.dart';
import 'package:mirascope/src/features/manga/data/dart_io_manga_reader_repository.dart';

import '../../../core/database/database_test_support.dart';

void main() {
  test('loads chapters and pages in their persisted order', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _seed(database);
    final repository = DartIoMangaReaderRepository(
      database,
      const DartIoMangaManifestScanner(FlutterMangaImageDecoder()),
    );
    final book = await repository.loadBook('media');
    expect(book?.chapters.map((chapter) => chapter.unit.id), [
      'chapter-1',
      'chapter-2',
    ]);
    expect(book?.pages.map((page) => page.id), ['page-1', 'page-2', 'page-3']);
  });
}

Future<void> _seed(AppDatabase database) async {
  final now = DateTime.utc(2026, 8, 15);
  await database
      .into(database.mediaItems)
      .insert(
        MediaItemsCompanion.insert(
          id: 'media',
          mediaType: 'manga',
          title: '漫画',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database.batch((batch) {
    batch.insertAll(database.contentUnits, [
      ContentUnitsCompanion.insert(
        id: 'chapter-2',
        mediaItemId: 'media',
        unitType: 'chapter',
        title: '二',
        orderIndex: 1,
        contentRef: 'c2',
        sourceLocator: '二',
        contentHash: 'h2',
      ),
      ContentUnitsCompanion.insert(
        id: 'chapter-1',
        mediaItemId: 'media',
        unitType: 'chapter',
        title: '一',
        orderIndex: 0,
        contentRef: 'c1',
        sourceLocator: '一',
        contentHash: 'h1',
      ),
    ]);
    batch.insertAll(database.mangaPages, [
      _page('page-3', 'chapter-2', 1),
      _page('page-2', 'chapter-2', 0),
      _page('page-1', 'chapter-1', 0),
    ]);
  });
}

MangaPagesCompanion _page(String id, String chapter, int order) =>
    MangaPagesCompanion.insert(
      id: id,
      contentUnitId: chapter,
      orderIndex: order,
      contentRef: id,
      sourceLocator: '$id.png',
      contentHash: 'hash-$id',
      mimeType: 'image/png',
      byteLength: 1,
    );
