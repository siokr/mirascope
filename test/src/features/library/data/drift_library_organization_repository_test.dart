import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/features/library/data/drift_library_organization_repository.dart';
import 'package:mirascope/src/features/library/domain/custom_shelf.dart'
    as domain;
import 'package:mirascope/src/features/library/domain/media_tag.dart' as domain;

import '../../../core/database/database_test_support.dart';

final _now = DateTime.utc(2026, 8, 16, 8);

void main() {
  test('creates trims sorts and renames tags', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftLibraryOrganizationRepository(database);

    await repository.createTag(
      domain.MediaTag(id: 'z', name: ' 科幻 ', createdAt: _now),
    );
    await repository.createTag(
      domain.MediaTag(id: 'a', name: 'Adventure', createdAt: _now),
    );

    expect((await repository.watchTags().first).map((tag) => tag.name), [
      'Adventure',
      '科幻',
    ]);
    await repository.renameTag('z', ' 奇幻 ');
    expect((await repository.watchTags().first).map((tag) => tag.name), [
      'Adventure',
      '奇幻',
    ]);
  });

  test('rejects blank and normalized duplicate organization names', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftLibraryOrganizationRepository(database);
    await repository.createTag(
      domain.MediaTag(id: 'tag', name: 'SciFi', createdAt: _now),
    );
    await repository.createShelf(
      domain.CustomShelf(
        id: 'shelf',
        name: '待读',
        createdAt: _now,
        updatedAt: _now,
      ),
    );

    await expectLater(
      repository.createTag(
        domain.MediaTag(id: 'duplicate', name: ' scifi ', createdAt: _now),
      ),
      throwsA(isA<Exception>()),
    );
    await expectLater(
      repository.createShelf(
        domain.CustomShelf(
          id: 'blank',
          name: '  ',
          createdAt: _now,
          updatedAt: _now,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('assigns and removes tags idempotently', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftLibraryOrganizationRepository(database);
    await _insertMedia(database);
    await repository.createTag(
      domain.MediaTag(id: 'tag', name: '收藏', createdAt: _now),
    );

    for (var i = 0; i < 2; i++) {
      await repository.setTagAssigned(
        tagId: 'tag',
        mediaItemId: 'media',
        assigned: true,
        changedAt: _now,
      );
    }
    expect(await repository.watchTagIdsForMedia('media').first, {'tag'});

    await repository.setTagAssigned(
      tagId: 'tag',
      mediaItemId: 'media',
      assigned: false,
      changedAt: _now,
    );
    expect(await repository.watchTagIdsForMedia('media').first, isEmpty);
  });

  test(
    'adds shelf items in order and keeps shelf after media removal',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final repository = DriftLibraryOrganizationRepository(database);
      await _insertMedia(database, id: 'first');
      await _insertMedia(database, id: 'second');
      await repository.createShelf(
        domain.CustomShelf(
          id: 'shelf',
          name: '待读',
          createdAt: _now,
          updatedAt: _now,
        ),
      );

      for (final id in ['first', 'second']) {
        await repository.setMediaInShelf(
          shelfId: 'shelf',
          mediaItemId: id,
          included: true,
          changedAt: _now,
        );
      }
      await repository.setMediaInShelf(
        shelfId: 'shelf',
        mediaItemId: 'first',
        included: true,
        changedAt: _now.add(const Duration(minutes: 1)),
      );
      final rows = await (database.select(
        database.customShelfItems,
      )..orderBy([(row) => OrderingTerm.asc(row.orderIndex)])).get();
      expect(rows.map((row) => row.mediaItemId), ['first', 'second']);
      expect(rows.map((row) => row.orderIndex), [0, 1]);
      expect(await repository.watchShelfIdsForMedia('second').first, {'shelf'});

      await (database.delete(
        database.mediaItems,
      )..where((row) => row.id.equals('first'))).go();
      expect(await repository.watchShelves().first, hasLength(1));
      expect(
        await database.select(database.customShelfItems).get(),
        hasLength(1),
      );
    },
  );
}

Future<void> _insertMedia(AppDatabase database, {String id = 'media'}) {
  return database
      .into(database.mediaItems)
      .insert(
        MediaItemsCompanion.insert(
          id: id,
          mediaType: 'novel',
          title: id,
          subtitle: const Value.absent(),
          creator: const Value.absent(),
          description: const Value.absent(),
          coverRef: const Value.absent(),
          createdAt: _now,
          updatedAt: _now,
        ),
      );
}
