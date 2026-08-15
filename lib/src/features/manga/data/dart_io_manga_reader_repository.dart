import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../importing/data/dart_io_manga_manifest_scanner.dart';
import '../../importing/domain/import_record.dart';
import '../../importing/domain/manga_source.dart';
import '../../library/domain/media_item.dart' as domain;
import '../../novel/domain/content_unit.dart' as domain;
import '../domain/manga_page.dart' as domain_page;
import '../domain/manga_reader_book.dart';

final class DartIoMangaReaderRepository implements MangaReaderRepository {
  const DartIoMangaReaderRepository(this.database, this.scanner);
  final AppDatabase database;
  final DartIoMangaManifestScanner scanner;

  @override
  Future<MangaReaderBook?> loadBook(String mediaItemId) async {
    final media =
        await (database.select(database.mediaItems)..where(
              (row) =>
                  row.id.equals(mediaItemId) & row.mediaType.equals('manga'),
            ))
            .getSingleOrNull();
    if (media == null) return null;
    final units =
        await (database.select(database.contentUnits)
              ..where((row) => row.mediaItemId.equals(mediaItemId))
              ..orderBy([(row) => OrderingTerm.asc(row.orderIndex)]))
            .get();
    final chapters = <MangaReaderChapter>[];
    for (final unit in units) {
      final rows =
          await (database.select(database.mangaPages)
                ..where((row) => row.contentUnitId.equals(unit.id))
                ..orderBy([(row) => OrderingTerm.asc(row.orderIndex)]))
              .get();
      chapters.add(
        MangaReaderChapter(
          unit: domain.ContentUnit(
            id: unit.id,
            mediaItemId: unit.mediaItemId,
            unitType: domain.ContentUnitType.fromStorageValue(unit.unitType),
            title: unit.title,
            orderIndex: unit.orderIndex,
            contentRef: unit.contentRef,
            sourceLocator: unit.sourceLocator,
            contentHash: unit.contentHash,
          ),
          pages: [for (final page in rows) _mapPage(page)],
        ),
      );
    }
    return MangaReaderBook(
      mediaItem: domain.MediaItem(
        id: media.id,
        mediaType: domain.MediaType.manga,
        title: media.title,
        subtitle: media.subtitle,
        creator: media.creator,
        description: media.description,
        coverRef: media.coverRef,
        createdAt: media.createdAt,
        updatedAt: media.updatedAt,
      ),
      chapters: chapters,
    );
  }

  @override
  Future<Uint8List> readPage(
    String mediaItemId,
    domain_page.MangaPage page,
  ) async {
    final source =
        await (database.select(database.importRecords)
              ..where(
                (row) =>
                    row.mediaItemId.equals(mediaItemId) &
                    row.status.equals('completed') &
                    row.sourceKind.isIn(['mangaDirectory', 'mangaArchive']),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    if (source == null) throw StateError('manga_source_unavailable');
    final kind =
        ImportSourceKind.fromStorageValue(source.sourceKind) ==
            ImportSourceKind.mangaArchive
        ? MangaSourceKind.archive
        : MangaSourceKind.directory;
    return scanner.readPage(
      MangaSourceSelection(path: source.sourcePath, kind: kind),
      page.sourceLocator,
    );
  }

  domain_page.MangaPage _mapPage(MangaPage page) => domain_page.MangaPage(
    id: page.id,
    contentUnitId: page.contentUnitId,
    orderIndex: page.orderIndex,
    contentRef: page.contentRef,
    sourceLocator: page.sourceLocator,
    contentHash: page.contentHash,
    imageType: domain_page.MangaImageType.fromStorageValue(page.mimeType),
    byteLength: page.byteLength,
    pixelWidth: page.pixelWidth,
    pixelHeight: page.pixelHeight,
  );
}
