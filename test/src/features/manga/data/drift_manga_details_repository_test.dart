import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/features/manga/data/drift_manga_details_repository.dart';

import '../../../core/database/database_test_support.dart';

void main() {
  test('loads ordered chapters, page counts and source state', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _seed(database);
    final details = await DriftMangaDetailsRepository(
      database,
      sourceExists: (_) async => true,
    ).findDetails('media');
    expect(details?.chapters.map((chapter) => chapter.unit.title), [
      '第一话',
      '第二话',
    ]);
    expect(details?.chapters.map((chapter) => chapter.pageCount), [2, 1]);
    expect(details?.sourceAvailable, isTrue);
  });

  test(
    'missing source is marked missing without deleting chapters or pages',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      await _seed(database);
      final details = await DriftMangaDetailsRepository(
        database,
        sourceExists: (_) async => false,
      ).findDetails('media');
      expect(details?.sourceAvailable, isFalse);
      expect(details?.pageCount, 3);
      expect(
        (await database.select(database.importRecords).getSingle()).status,
        'missing',
      );
      expect(await database.select(database.mangaPages).get(), hasLength(3));
    },
  );
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
  await database
      .into(database.libraryEntries)
      .insert(
        LibraryEntriesCompanion.insert(
          id: 'library',
          mediaItemId: 'media',
          favorite: false,
          addedAt: now,
        ),
      );
  await database.batch((batch) {
    batch.insertAll(database.contentUnits, [
      ContentUnitsCompanion.insert(
        id: 'chapter-2',
        mediaItemId: 'media',
        unitType: 'chapter',
        title: '第二话',
        orderIndex: 1,
        contentRef: 'chapter/2',
        sourceLocator: '第二话',
        contentHash: 'hash-2',
      ),
      ContentUnitsCompanion.insert(
        id: 'chapter-1',
        mediaItemId: 'media',
        unitType: 'chapter',
        title: '第一话',
        orderIndex: 0,
        contentRef: 'chapter/1',
        sourceLocator: '第一话',
        contentHash: 'hash-1',
      ),
    ]);
    batch.insertAll(database.mangaPages, [
      MangaPagesCompanion.insert(
        id: 'p2',
        contentUnitId: 'chapter-1',
        orderIndex: 1,
        contentRef: 'p2',
        sourceLocator: '2.png',
        contentHash: 'h2',
        mimeType: 'image/png',
        byteLength: 1,
      ),
      MangaPagesCompanion.insert(
        id: 'p1',
        contentUnitId: 'chapter-1',
        orderIndex: 0,
        contentRef: 'p1',
        sourceLocator: '1.png',
        contentHash: 'h1',
        mimeType: 'image/png',
        byteLength: 1,
      ),
      MangaPagesCompanion.insert(
        id: 'p3',
        contentUnitId: 'chapter-2',
        orderIndex: 0,
        contentRef: 'p3',
        sourceLocator: '1.png',
        contentHash: 'h3',
        mimeType: 'image/png',
        byteLength: 1,
      ),
    ]);
  });
  await database
      .into(database.importRecords)
      .insert(
        ImportRecordsCompanion.insert(
          id: 'import',
          mediaItemId: const Value('media'),
          sourcePath: 'book.cbz',
          sourceKind: 'mangaArchive',
          fileSize: 3,
          fingerprint: 'fingerprint',
          status: 'completed',
          createdAt: now,
        ),
      );
}
