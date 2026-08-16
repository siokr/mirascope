import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/custom_shelf.dart' as domain;
import '../domain/library_organization_repository.dart';
import '../domain/media_tag.dart' as domain;

final class DriftLibraryOrganizationRepository
    implements LibraryOrganizationRepository {
  DriftLibraryOrganizationRepository(this.database);

  final AppDatabase database;

  @override
  Stream<List<domain.MediaTag>> watchTags() {
    final query = database.select(database.tags)
      ..orderBy([(row) => OrderingTerm.asc(row.normalizedName)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => domain.MediaTag(
              id: row.id,
              name: row.name,
              createdAt: row.createdAt,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Stream<Set<String>> watchTagIdsForMedia(String mediaItemId) {
    final query = database.select(database.mediaTagAssignments)
      ..where((row) => row.mediaItemId.equals(mediaItemId));
    return query.watch().map((rows) => {for (final row in rows) row.tagId});
  }

  @override
  Future<void> createTag(domain.MediaTag tag) async {
    final name = _cleanName(tag.name);
    await database
        .into(database.tags)
        .insert(
          TagsCompanion.insert(
            id: tag.id,
            name: name,
            normalizedName: _normalizedName(name),
            createdAt: tag.createdAt.toUtc(),
          ),
        );
  }

  @override
  Future<void> renameTag(String tagId, String name) async {
    final cleanName = _cleanName(name);
    final updated =
        await (database.update(
          database.tags,
        )..where((row) => row.id.equals(tagId))).write(
          TagsCompanion(
            name: Value(cleanName),
            normalizedName: Value(_normalizedName(cleanName)),
          ),
        );
    if (updated != 1) throw StateError('tag_not_found');
  }

  @override
  Future<void> deleteTag(String tagId) async {
    await (database.delete(
      database.tags,
    )..where((row) => row.id.equals(tagId))).go();
  }

  @override
  Future<void> setTagAssigned({
    required String tagId,
    required String mediaItemId,
    required bool assigned,
    required DateTime changedAt,
  }) async {
    if (!assigned) {
      await (database.delete(database.mediaTagAssignments)..where(
            (row) =>
                row.tagId.equals(tagId) & row.mediaItemId.equals(mediaItemId),
          ))
          .go();
      return;
    }
    await database
        .into(database.mediaTagAssignments)
        .insertOnConflictUpdate(
          MediaTagAssignmentsCompanion.insert(
            tagId: tagId,
            mediaItemId: mediaItemId,
            createdAt: changedAt.toUtc(),
          ),
        );
  }

  @override
  Stream<List<domain.CustomShelf>> watchShelves() {
    final query = database.select(database.customShelves)
      ..orderBy([(row) => OrderingTerm.asc(row.normalizedName)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => domain.CustomShelf(
              id: row.id,
              name: row.name,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Stream<Set<String>> watchShelfIdsForMedia(String mediaItemId) {
    final query = database.select(database.customShelfItems)
      ..where((row) => row.mediaItemId.equals(mediaItemId));
    return query.watch().map((rows) => {for (final row in rows) row.shelfId});
  }

  @override
  Future<void> createShelf(domain.CustomShelf shelf) async {
    final name = _cleanName(shelf.name);
    await database
        .into(database.customShelves)
        .insert(
          CustomShelvesCompanion.insert(
            id: shelf.id,
            name: name,
            normalizedName: _normalizedName(name),
            createdAt: shelf.createdAt.toUtc(),
            updatedAt: shelf.updatedAt.toUtc(),
          ),
        );
  }

  @override
  Future<void> renameShelf(
    String shelfId,
    String name,
    DateTime updatedAt,
  ) async {
    final cleanName = _cleanName(name);
    final updated =
        await (database.update(
          database.customShelves,
        )..where((row) => row.id.equals(shelfId))).write(
          CustomShelvesCompanion(
            name: Value(cleanName),
            normalizedName: Value(_normalizedName(cleanName)),
            updatedAt: Value(updatedAt.toUtc()),
          ),
        );
    if (updated != 1) throw StateError('shelf_not_found');
  }

  @override
  Future<void> deleteShelf(String shelfId) async {
    await (database.delete(
      database.customShelves,
    )..where((row) => row.id.equals(shelfId))).go();
  }

  @override
  Future<void> setMediaInShelf({
    required String shelfId,
    required String mediaItemId,
    required bool included,
    required DateTime changedAt,
  }) async {
    if (!included) {
      await (database.delete(database.customShelfItems)..where(
            (row) =>
                row.shelfId.equals(shelfId) &
                row.mediaItemId.equals(mediaItemId),
          ))
          .go();
      return;
    }
    await database.transaction(() async {
      final existing =
          await (database.select(database.customShelfItems)..where(
                (row) =>
                    row.shelfId.equals(shelfId) &
                    row.mediaItemId.equals(mediaItemId),
              ))
              .getSingleOrNull();
      if (existing != null) return;
      final maxOrder = database.customShelfItems.orderIndex.max();
      final nextOrder =
          await (database.selectOnly(database.customShelfItems)
                ..addColumns([maxOrder])
                ..where(database.customShelfItems.shelfId.equals(shelfId)))
              .map((row) => row.read(maxOrder) ?? -1)
              .getSingle() +
          1;
      await database
          .into(database.customShelfItems)
          .insert(
            CustomShelfItemsCompanion.insert(
              shelfId: shelfId,
              mediaItemId: mediaItemId,
              orderIndex: nextOrder,
              addedAt: changedAt.toUtc(),
            ),
          );
    });
  }

  String _cleanName(String name) {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError.value(name, 'name', '名称不能为空');
    return clean;
  }

  String _normalizedName(String name) => name.toLowerCase();
}
