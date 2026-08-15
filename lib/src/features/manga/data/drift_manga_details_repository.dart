import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../importing/domain/import_record.dart';
import '../../library/domain/media_item.dart' as domain;
import '../../novel/domain/content_unit.dart' as domain;
import '../domain/manga_details.dart';
import '../domain/manga_details_repository.dart';

typedef MangaSourceExists = Future<bool> Function(String path);

final class DriftMangaDetailsRepository implements MangaDetailsRepository {
  DriftMangaDetailsRepository(this.database, {MangaSourceExists? sourceExists})
    : sourceExists =
          sourceExists ??
          ((path) => FileSystemEntity.type(
            path,
          ).then((type) => type != FileSystemEntityType.notFound));

  final AppDatabase database;
  final MangaSourceExists sourceExists;

  @override
  Future<MangaDetails?> findDetails(String mediaItemId) async {
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
    final counts = <String, int>{};
    for (final unit in units) {
      final count = database.mangaPages.id.count();
      final query = database.selectOnly(database.mangaPages)
        ..addColumns([count])
        ..where(database.mangaPages.contentUnitId.equals(unit.id));
      counts[unit.id] =
          (await query.map((row) => row.read(count)).getSingle()) ?? 0;
    }
    final source =
        await (database.select(database.importRecords)
              ..where(
                (row) =>
                    row.mediaItemId.equals(mediaItemId) &
                    row.status.isIn(['completed', 'missing']) &
                    row.sourceKind.isIn(['mangaDirectory', 'mangaArchive']),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    var available = false;
    if (source != null) {
      available =
          source.status == 'completed' && await sourceExists(source.sourcePath);
      if (!available && source.status == 'completed') {
        await (database.update(database.importRecords)..where(
              (row) =>
                  row.id.equals(source.id) & row.status.equals('completed'),
            ))
            .write(const ImportRecordsCompanion(status: Value('missing')));
      }
    }
    return MangaDetails(
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
      chapters: [
        for (final unit in units)
          MangaChapterDetails(
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
            pageCount: counts[unit.id] ?? 0,
          ),
      ],
      sourceAvailable: available,
      sourceKind: source == null
          ? null
          : ImportSourceKind.fromStorageValue(source.sourceKind),
    );
  }
}
