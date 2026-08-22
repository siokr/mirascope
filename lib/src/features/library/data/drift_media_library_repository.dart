import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/library_item.dart' as domain;
import '../domain/library_entry.dart' as domain;
import '../domain/library_query.dart';
import '../domain/media_item.dart' as domain;
import '../domain/media_library_repository.dart';

final class DriftMediaLibraryRepository implements MediaLibraryRepository {
  DriftMediaLibraryRepository(this.database);

  final AppDatabase database;

  @override
  Stream<List<domain.LibraryItem>> watchActiveLibrary() {
    return watchLibrary(const LibraryQuery());
  }

  @override
  Stream<List<domain.LibraryItem>> watchArchivedLibrary() {
    return watchLibrary(
      const LibraryQuery(archived: true, sort: LibrarySort.recentlyAdded),
    );
  }

  @override
  Stream<List<domain.LibraryItem>> watchLibrary(LibraryQuery libraryQuery) {
    final query = database.select(database.libraryEntries).join([
      innerJoin(
        database.mediaItems,
        database.mediaItems.id.equalsExp(database.libraryEntries.mediaItemId),
      ),
    ]);
    if (libraryQuery.archived) {
      query.where(database.libraryEntries.archivedAt.isNotNull());
    } else {
      query.where(database.libraryEntries.archivedAt.isNull());
    }
    if (libraryQuery.favoriteOnly) {
      query.where(database.libraryEntries.favorite.equals(true));
    }
    if (libraryQuery.tagId case final tagId?) {
      final taggedMedia = database.selectOnly(database.mediaTagAssignments)
        ..addColumns([database.mediaTagAssignments.mediaItemId])
        ..where(database.mediaTagAssignments.tagId.equals(tagId));
      query.where(database.mediaItems.id.isInQuery(taggedMedia));
    }
    if (libraryQuery.shelfId case final shelfId?) {
      final shelvedMedia = database.selectOnly(database.customShelfItems)
        ..addColumns([database.customShelfItems.mediaItemId])
        ..where(database.customShelfItems.shelfId.equals(shelfId));
      query.where(database.mediaItems.id.isInQuery(shelvedMedia));
    }
    if (libraryQuery.mediaTypes.isNotEmpty) {
      query.where(
        database.mediaItems.mediaType.isIn(
          libraryQuery.mediaTypes.map((type) => type.storageValue),
        ),
      );
    }
    final searchText = libraryQuery.normalizedSearchText;
    if (searchText.isNotEmpty) {
      query.where(
        database.mediaItems.title.lower().contains(searchText) |
            database.mediaItems.subtitle.lower().contains(searchText) |
            database.mediaItems.creator.lower().contains(searchText),
      );
    }
    query.orderBy(_orderTerms(libraryQuery));

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

  List<OrderingTerm> _orderTerms(LibraryQuery query) {
    final stableId = OrderingTerm(
      expression: database.libraryEntries.id,
      mode: OrderingMode.asc,
    );
    return switch (query.sort) {
      LibrarySort.recentlyOpened when query.archived => [
        OrderingTerm(
          expression: database.libraryEntries.archivedAt,
          mode: OrderingMode.desc,
        ),
        OrderingTerm(
          expression: database.libraryEntries.addedAt,
          mode: OrderingMode.desc,
        ),
        stableId,
      ],
      LibrarySort.recentlyOpened => [
        OrderingTerm(
          expression: database.libraryEntries.lastOpenedAt,
          mode: OrderingMode.desc,
        ),
        OrderingTerm(
          expression: database.libraryEntries.addedAt,
          mode: OrderingMode.desc,
        ),
        stableId,
      ],
      LibrarySort.recentlyAdded => [
        OrderingTerm(
          expression: query.archived
              ? database.libraryEntries.archivedAt
              : database.libraryEntries.addedAt,
          mode: OrderingMode.desc,
        ),
        OrderingTerm(
          expression: database.libraryEntries.addedAt,
          mode: OrderingMode.desc,
        ),
        stableId,
      ],
      LibrarySort.titleAscending => [
        OrderingTerm(
          expression: database.mediaItems.title.lower(),
          mode: OrderingMode.asc,
        ),
        stableId,
      ],
      LibrarySort.titleDescending => [
        OrderingTerm(
          expression: database.mediaItems.title.lower(),
          mode: OrderingMode.desc,
        ),
        stableId,
      ],
    };
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
                  row.mediaItemId.equals(mediaItemId) & row.archivedAt.isNull(),
            ))
            .write(
              LibraryEntriesCompanion(lastOpenedAt: Value(openedAt.toUtc())),
            );
    if (updated != 1) {
      throw StateError('library_entry_not_active');
    }
  }

  @override
  Future<void> setFavorite(String mediaItemId, bool favorite) async {
    final updated =
        await (database.update(database.libraryEntries)..where(
              (row) =>
                  row.mediaItemId.equals(mediaItemId) & row.archivedAt.isNull(),
            ))
            .write(LibraryEntriesCompanion(favorite: Value(favorite)));
    if (updated != 1) throw StateError('library_entry_not_active');
  }

  @override
  Future<void> archive(String mediaItemId, DateTime archivedAt) async {
    final updated =
        await (database.update(database.libraryEntries)..where(
              (row) =>
                  row.mediaItemId.equals(mediaItemId) & row.archivedAt.isNull(),
            ))
            .write(
              LibraryEntriesCompanion(archivedAt: Value(archivedAt.toUtc())),
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
  Future<Set<String>> deleteApplicationData(String mediaItemId) async {
    return database.transaction(() async {
      final archivedEntry =
          await (database.select(database.libraryEntries)..where(
                (row) =>
                    row.mediaItemId.equals(mediaItemId) &
                    row.archivedAt.isNotNull(),
              ))
              .getSingleOrNull();
      if (archivedEntry == null) {
        throw StateError('library_entry_not_archived');
      }
      final units = await (database.select(
        database.contentUnits,
      )..where((row) => row.mediaItemId.equals(mediaItemId))).get();
      final deleted = await (database.delete(
        database.mediaItems,
      )..where((row) => row.id.equals(mediaItemId))).go();
      if (deleted != 1) {
        throw StateError('media_item_not_found');
      }
      return {for (final unit in units) unit.contentRef};
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
