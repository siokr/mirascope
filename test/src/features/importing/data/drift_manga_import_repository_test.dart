import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/importing/data/drift_import_repository.dart';
import 'package:mirascope/src/features/importing/domain/import_record.dart';
import 'package:mirascope/src/features/importing/domain/successful_import.dart';
import 'package:mirascope/src/features/library/domain/library_entry.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/manga/domain/manga_page.dart';
import 'package:mirascope/src/features/novel/domain/content_unit.dart';

import '../../../core/database/database_test_support.dart';

void main() {
  test('writes manga pages in the same aggregate transaction', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftImportRepository(database);

    await repository.commitSuccessfulImport(_mangaImport());

    final pages = await database.select(database.mangaPages).get();
    expect(pages, hasLength(1));
    expect(pages.single.contentUnitId, 'chapter');
    expect(pages.single.mimeType, 'image/png');
    expect(pages.single.pixelWidth, 10);
  });

  test('invalid page ownership fails before any database write', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftImportRepository(database);
    final valid = _mangaImport();
    final invalid = SuccessfulImport(
      mediaItem: valid.mediaItem,
      libraryEntry: valid.libraryEntry,
      contentUnits: valid.contentUnits,
      mangaPages: const [
        MangaPage(
          id: 'page',
          contentUnitId: 'another',
          orderIndex: 0,
          contentRef: 'source:1.png',
          sourceLocator: '1.png',
          contentHash: 'hash',
          imageType: MangaImageType.png,
          byteLength: 10,
          pixelWidth: 10,
          pixelHeight: 20,
        ),
      ],
      importRecord: valid.importRecord,
    );

    await expectLater(
      repository.commitSuccessfulImport(invalid),
      throwsArgumentError,
    );
    expect(await database.select(database.mediaItems).get(), isEmpty);
  });
}

SuccessfulImport _mangaImport() {
  final now = DateTime.utc(2026, 8, 15);
  return SuccessfulImport(
    mediaItem: MediaItem(
      id: 'media',
      mediaType: MediaType.manga,
      title: '漫画',
      coverRef: 'manga/media/cover.png',
      createdAt: now,
      updatedAt: now,
    ),
    libraryEntry: LibraryEntry(
      id: 'library',
      mediaItemId: 'media',
      favorite: false,
      addedAt: now,
    ),
    contentUnits: const [
      ContentUnit(
        id: 'chapter',
        mediaItemId: 'media',
        unitType: ContentUnitType.chapter,
        title: '第一话',
        orderIndex: 0,
        contentRef: 'manga/media/chapters/0',
        sourceLocator: 'chapter',
        contentHash: 'chapter-hash',
      ),
    ],
    mangaPages: const [
      MangaPage(
        id: 'page',
        contentUnitId: 'chapter',
        orderIndex: 0,
        contentRef: 'source:1.png',
        sourceLocator: '1.png',
        contentHash: 'hash',
        imageType: MangaImageType.png,
        byteLength: 10,
        pixelWidth: 10,
        pixelHeight: 20,
      ),
    ],
    importRecord: ImportRecord(
      id: 'import',
      mediaItemId: 'media',
      sourcePath: 'book.cbz',
      sourceKind: ImportSourceKind.mangaArchive,
      fileSize: 10,
      fingerprint: 'fingerprint',
      status: ImportStatus.completed,
      createdAt: now,
    ),
  );
}
