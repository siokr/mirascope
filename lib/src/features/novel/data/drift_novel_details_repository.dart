import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../library/domain/media_item.dart' as domain;
import '../domain/content_unit.dart' as domain;
import '../domain/novel_details.dart';
import '../domain/novel_details_repository.dart';

typedef SourceExists = Future<bool> Function(String path);

final class DriftNovelDetailsRepository implements NovelDetailsRepository {
  DriftNovelDetailsRepository(this.database, {SourceExists? sourceExists})
    : sourceExists = sourceExists ?? ((path) => File(path).exists());

  final AppDatabase database;
  final SourceExists sourceExists;

  @override
  Future<NovelDetails?> findDetails(String mediaItemId) async {
    final media = await (database.select(
      database.mediaItems,
    )..where((row) => row.id.equals(mediaItemId))).getSingleOrNull();
    if (media == null) return null;

    final units =
        await (database.select(database.contentUnits)
              ..where((row) => row.mediaItemId.equals(mediaItemId))
              ..orderBy([(row) => OrderingTerm.asc(row.orderIndex)]))
            .get();
    final source =
        await (database.select(database.importRecords)
              ..where(
                (row) =>
                    row.mediaItemId.equals(mediaItemId) &
                    row.status.equals('completed') &
                    row.sourceKind.equals('txtFile'),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)])
              ..limit(1))
            .getSingleOrNull();

    return NovelDetails(
      mediaItem: domain.MediaItem(
        id: media.id,
        mediaType: domain.MediaType.fromStorageValue(media.mediaType),
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
          domain.ContentUnit(
            id: unit.id,
            mediaItemId: unit.mediaItemId,
            unitType: domain.ContentUnitType.fromStorageValue(unit.unitType),
            title: unit.title,
            orderIndex: unit.orderIndex,
            contentRef: unit.contentRef,
            sourceLocator: unit.sourceLocator,
            contentHash: unit.contentHash,
          ),
      ],
      sourceAvailable: source != null && await sourceExists(source.sourcePath),
    );
  }
}
