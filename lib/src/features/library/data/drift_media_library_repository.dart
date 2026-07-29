import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/library_item.dart' as domain;
import '../domain/library_entry.dart' as domain;
import '../domain/media_item.dart' as domain;
import '../domain/media_library_repository.dart';

final class DriftMediaLibraryRepository implements MediaLibraryRepository {
  DriftMediaLibraryRepository(this.database);

  final AppDatabase database;

  @override
  Stream<List<domain.LibraryItem>> watchActiveLibrary() {
    return _watchLibrary(archived: false);
  }

  @override
  Stream<List<domain.LibraryItem>> watchArchivedLibrary() {
    return _watchLibrary(archived: true);
  }

  Stream<List<domain.LibraryItem>> _watchLibrary({required bool archived}) {
    final query = database.select(database.libraryEntries).join([
      innerJoin(
        database.mediaItems,
        database.mediaItems.id.equalsExp(database.libraryEntries.mediaItemId),
      ),
    ]);
    if (archived) {
      query
        ..where(database.libraryEntries.archivedAt.isNotNull())
        ..orderBy([
          OrderingTerm(
            expression: database.libraryEntries.archivedAt,
            mode: OrderingMode.desc,
          ),
          OrderingTerm(
            expression: database.libraryEntries.addedAt,
            mode: OrderingMode.desc,
          ),
          OrderingTerm(
            expression: database.libraryEntries.id,
            mode: OrderingMode.asc,
          ),
        ]);
    } else {
      query
        ..where(database.libraryEntries.archivedAt.isNull())
        ..orderBy([
          OrderingTerm(
            expression: database.libraryEntries.lastOpenedAt,
            mode: OrderingMode.desc,
          ),
          OrderingTerm(
            expression: database.libraryEntries.addedAt,
            mode: OrderingMode.desc,
          ),
          OrderingTerm(
            expression: database.libraryEntries.id,
            mode: OrderingMode.asc,
          ),
        ]);
    }

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => _toLibraryItem(
              row.readTable(database.mediaItems),
              row.readTable(database.libraryEntries),
            ),
          )
          .toList(),
    );
  }

  @override
  Future<domain.MediaItem?> findMediaItem(String mediaItemId) async {
    final mediaItem = await (database.select(
      database.mediaItems,
    )..where((row) => row.id.equals(mediaItemId))).getSingleOrNull();

    return mediaItem == null ? null : _toMediaItem(mediaItem);
  }

  @override
  Future<void> markOpened(String mediaItemId, DateTime openedAt) async {
    final updated =
        await (database.update(database.libraryEntries)..where(
              (row) =>
                  row.mediaItemId.equals(mediaItemId) &
                  row.archivedAt.isNull(),
            ))
            .write(
              LibraryEntriesCompanion(
                lastOpenedAt: Value(openedAt.toUtc()),
              ),
            );
    if (updated != 1) {
      throw StateError('library_entry_not_active');
    }
  }

  @override
  Future<void> archive(String mediaItemId, DateTime archivedAt) async {
    final updated =
        await (database.update(database.libraryEntries)..where(
              (row) =>
                  row.mediaItemId.equals(mediaItemId) &
                  row.archivedAt.isNull(),
            ))
            .write(
              LibraryEntriesCompanion(
                archivedAt: Value(archivedAt.toUtc()),
              ),
            );
    if (updated != 1) {
      throw StateError('library_entry_not_active');
    }
  }

  @override
  Future<void> restore(String mediaItemId) async {
    final updated =
        await (database.update(database.libraryEntries)..where(
              (row) =>
                  row.mediaItemId.equals(mediaItemId) &
                  row.archivedAt.isNotNull(),
            ))
            .write(const LibraryEntriesCompanion(archivedAt: Value(null)));
    if (updated != 1) {
      throw StateError('library_entry_not_archived');
    }
  }

  @override
  Future<void> deleteApplicationData(String mediaItemId) async {
    await database.transaction(() async {
      await (database.delete(
        database.mediaItems,
      )..where((row) => row.id.equals(mediaItemId))).go();
    });
  }

  domain.LibraryItem _toLibraryItem(MediaItem mediaItem, LibraryEntry entry) {
    return domain.LibraryItem(
      mediaItem: _toMediaItem(mediaItem),
      libraryEntry: domain.LibraryEntry(
        id: entry.id,
        mediaItemId: entry.mediaItemId,
        favorite: entry.favorite,
        addedAt: entry.addedAt,
        lastOpenedAt: entry.lastOpenedAt,
        archivedAt: entry.archivedAt,
      ),
    );
  }

  domain.MediaItem _toMediaItem(MediaItem mediaItem) {
    return domain.MediaItem(
      id: mediaItem.id,
      mediaType: domain.MediaType.fromStorageValue(mediaItem.mediaType),
      title: mediaItem.title,
      subtitle: mediaItem.subtitle,
      creator: mediaItem.creator,
      description: mediaItem.description,
      coverRef: mediaItem.coverRef,
      createdAt: mediaItem.createdAt,
      updatedAt: mediaItem.updatedAt,
    );
  }
}
