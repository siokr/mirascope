import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/features/library/data/drift_media_library_repository.dart';
import 'package:mirascope/src/features/library/domain/library_query.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart'
    as domain;

import '../../../core/database/database_test_support.dart';

final _now = DateTime.utc(2026, 7, 28, 9);

void main() {
  test('active stream excludes archived entries', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(database, id: 'active', title: 'Active');
    await _insertMediaAndLibraryEntry(
      database,
      id: 'archived',
      title: 'Archived',
      archivedAt: _now,
    );

    final items = await repository.watchActiveLibrary().first;

    expect(items.map((item) => item.mediaItem.id).toList(), ['active']);
  });

  test('archived stream contains only archived entries', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(database, id: 'active', title: 'Active');
    await _insertMediaAndLibraryEntry(
      database,
      id: 'archived',
      title: 'Archived',
      archivedAt: _now,
    );

    final items = await repository.watchArchivedLibrary().first;

    expect(items.map((item) => item.mediaItem.id).toList(), ['archived']);
  });

  test(
    'query searches title subtitle and creator case-insensitively',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final repository = DriftMediaLibraryRepository(database);
      await _insertMediaAndLibraryEntry(
        database,
        id: 'title',
        title: 'DART 入门',
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'subtitle',
        title: 'Second',
        subtitle: 'Flutter DART',
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'creator',
        title: 'Third',
        creator: 'Dart Author',
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'other',
        title: 'Unrelated',
      );

      final items = await repository
          .watchLibrary(const LibraryQuery(searchText: '  dArT  '))
          .first;

      expect(items.map((item) => item.mediaItem.id), [
        'creator',
        'subtitle',
        'title',
      ]);
    },
  );

  test('query combines media type and favorite filters', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(
      database,
      id: 'favorite-manga',
      title: 'Favorite manga',
      mediaType: 'manga',
      favorite: true,
    );
    await _insertMediaAndLibraryEntry(
      database,
      id: 'plain-manga',
      title: 'Plain manga',
      mediaType: 'manga',
    );
    await _insertMediaAndLibraryEntry(
      database,
      id: 'favorite-novel',
      title: 'Favorite novel',
      favorite: true,
    );

    final items = await repository
        .watchLibrary(
          const LibraryQuery(
            mediaTypes: {domain.MediaType.manga},
            favoriteOnly: true,
          ),
        )
        .first;

    expect(items.single.mediaItem.id, 'favorite-manga');
  });

  test('query supports stable title sorting in both directions', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(
      database,
      id: 'z',
      entryId: 'entry-z',
      title: 'beta',
    );
    await _insertMediaAndLibraryEntry(
      database,
      id: 'b',
      entryId: 'entry-b',
      title: 'Alpha',
    );
    await _insertMediaAndLibraryEntry(
      database,
      id: 'a',
      entryId: 'entry-a',
      title: 'alpha',
    );

    final ascending = await repository
        .watchLibrary(const LibraryQuery(sort: LibrarySort.titleAscending))
        .first;
    final descending = await repository
        .watchLibrary(const LibraryQuery(sort: LibrarySort.titleDescending))
        .first;

    expect(ascending.map((item) => item.mediaItem.id), ['a', 'b', 'z']);
    expect(descending.map((item) => item.mediaItem.id), ['z', 'a', 'b']);
  });

  test('archive removes an item from the active stream', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(database, id: 'media-1', title: 'Book');
    final iterator = StreamIterator(repository.watchActiveLibrary());
    addTearDown(iterator.cancel);

    await iterator.moveNext();
    expect(iterator.current, hasLength(1));

    await repository.archive('media-1', _now);
    await iterator.moveNext();

    expect(iterator.current, isEmpty);
  });

  test('restore returns the same library entry ID', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(
      database,
      id: 'media-1',
      title: 'Book',
      archivedAt: _now,
    );

    await repository.restore('media-1');
    final entry = await (database.select(
      database.libraryEntries,
    )..where((row) => row.mediaItemId.equals('media-1'))).getSingle();

    expect(entry.id, 'entry-media-1');
    expect(entry.archivedAt, isNull);
  });

  test(
    'results order by lastOpenedAt descending then addedAt descending',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final repository = DriftMediaLibraryRepository(database);
      await _insertMediaAndLibraryEntry(
        database,
        id: 'older-opened',
        title: 'Older opened',
        addedAt: _now.add(const Duration(hours: 1)),
        lastOpenedAt: _now.add(const Duration(hours: 2)),
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'newer-opened',
        title: 'Newer opened',
        addedAt: _now,
        lastOpenedAt: _now.add(const Duration(hours: 3)),
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'newer-unopened',
        title: 'Newer unopened',
        addedAt: _now.add(const Duration(hours: 4)),
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'older-unopened',
        title: 'Older unopened',
        addedAt: _now.add(const Duration(hours: 2)),
      );

      final items = await repository.watchActiveLibrary().first;

      expect(items.map((item) => item.mediaItem.id).toList(), [
        'newer-opened',
        'older-opened',
        'newer-unopened',
        'older-unopened',
      ]);
    },
  );

  test('active ordering uses entry id as a stable final tie-breaker', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(
      database,
      id: 'z-last',
      entryId: 'entry-z',
      title: 'Z',
    );
    await _insertMediaAndLibraryEntry(
      database,
      id: 'a-first',
      entryId: 'entry-a',
      title: 'A',
    );

    final items = await repository.watchActiveLibrary().first;

    expect(items.map((item) => item.mediaItem.id).toList(), [
      'a-first',
      'z-last',
    ]);
  });

  test(
    'archived ordering uses archivedAt then addedAt then entry id',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final repository = DriftMediaLibraryRepository(database);
      await _insertMediaAndLibraryEntry(
        database,
        id: 'older-archive',
        title: 'Older archive',
        archivedAt: _now,
        addedAt: _now.add(const Duration(hours: 4)),
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'newer-added-z',
        entryId: 'entry-z',
        title: 'Newer added Z',
        archivedAt: _now.add(const Duration(hours: 1)),
        addedAt: _now.add(const Duration(hours: 3)),
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'newer-added-a',
        entryId: 'entry-a',
        title: 'Newer added A',
        archivedAt: _now.add(const Duration(hours: 1)),
        addedAt: _now.add(const Duration(hours: 3)),
      );
      await _insertMediaAndLibraryEntry(
        database,
        id: 'same-archive-older-added',
        title: 'Same archive older added',
        archivedAt: _now.add(const Duration(hours: 1)),
        addedAt: _now.add(const Duration(hours: 2)),
      );

      final items = await repository.watchArchivedLibrary().first;

      expect(items.map((item) => item.mediaItem.id).toList(), [
        'newer-added-a',
        'newer-added-z',
        'same-archive-older-added',
        'older-archive',
      ]);
    },
  );

  test('markOpened stores UTC and moves the item to the front', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(
      database,
      id: 'already-opened',
      title: 'Already opened',
      lastOpenedAt: _now,
    );
    await _insertMediaAndLibraryEntry(
      database,
      id: 'newly-opened',
      title: 'Newly opened',
    );
    final localTime = DateTime(2026, 7, 29, 18, 30);

    await repository.markOpened('newly-opened', localTime);

    final items = await repository.watchActiveLibrary().first;
    final updated = items.first.libraryEntry.lastOpenedAt;
    expect(items.first.mediaItem.id, 'newly-opened');
    expect(updated, localTime.toUtc());
    expect(updated!.isUtc, isTrue);
  });

  test('markOpened rejects archived and missing entries', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(
      database,
      id: 'archived',
      title: 'Archived',
      archivedAt: _now,
    );

    await expectLater(
      repository.markOpened('archived', _now),
      throwsStateError,
    );
    await expectLater(repository.markOpened('missing', _now), throwsStateError);
  });

  test('archive and restore reject invalid current states', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(database, id: 'active', title: 'Active');
    await _insertMediaAndLibraryEntry(
      database,
      id: 'archived',
      title: 'Archived',
      archivedAt: _now,
    );

    await expectLater(repository.archive('archived', _now), throwsStateError);
    await expectLater(repository.archive('missing', _now), throwsStateError);
    await expectLater(repository.restore('active'), throwsStateError);
    await expectLater(repository.restore('missing'), throwsStateError);
  });

  test('deleting a media item removes database dependents', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(
      database,
      id: 'media-1',
      title: 'Book',
      archivedAt: _now,
    );
    await database
        .into(database.contentUnits)
        .insert(
          ContentUnitsCompanion.insert(
            id: 'unit-1',
            mediaItemId: 'media-1',
            unitType: 'chapter',
            title: 'Chapter 1',
            orderIndex: 0,
            contentRef: 'content/unit-1',
            sourceLocator: 'source#chapter-1',
            contentHash: 'hash-1',
          ),
        );
    await database
        .into(database.readingProgressEntries)
        .insert(
          ReadingProgressEntriesCompanion.insert(
            id: 'progress-1',
            mediaItemId: 'media-1',
            contentUnitId: 'unit-1',
            locator: 'paragraph:1',
            fraction: 0.5,
            updatedAt: _now,
            revision: 0,
          ),
        );
    await database
        .into(database.readerPreferences)
        .insert(
          ReaderPreferencesCompanion.insert(
            id: 'preference-1',
            scope: 'mediaItem',
            mediaItemId: const Value('media-1'),
            updatedAt: _now,
          ),
        );
    await database
        .into(database.importRecords)
        .insert(
          ImportRecordsCompanion.insert(
            id: 'import-1',
            mediaItemId: const Value('media-1'),
            sourcePath: 'C:/books/book.txt',
            sourceKind: 'txtFile',
            fileSize: 100,
            fingerprint: 'fingerprint-1',
            status: 'completed',
            createdAt: _now,
          ),
        );

    final contentRefs = await repository.deleteApplicationData('media-1');

    expect(contentRefs, {'content/unit-1'});
    expect(await repository.findMediaItem('media-1'), isNull);
    expect(await database.select(database.libraryEntries).get(), isEmpty);
    expect(await database.select(database.contentUnits).get(), isEmpty);
    expect(
      await database.select(database.readingProgressEntries).get(),
      isEmpty,
    );
    expect(await database.select(database.readerPreferences).get(), isEmpty);
    expect(await database.select(database.importRecords).get(), isEmpty);
  });

  test('permanent deletion rejects an active library item', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(database, id: 'active', title: 'Active');

    await expectLater(
      repository.deleteApplicationData('active'),
      throwsStateError,
    );
    expect(await repository.findMediaItem('active'), isNotNull);
  });

  test(
    'favorite changes are persisted and emitted by the library stream',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final repository = DriftMediaLibraryRepository(database);
      await _insertMediaAndLibraryEntry(database, id: 'book', title: 'Book');

      await repository.setFavorite('book', true);

      final favorites =
          await repository
                  .watchLibrary(const LibraryQuery(favoriteOnly: true))
                  .first
              as List<Object?>;
      expect(favorites, hasLength(1));
      expect(
        (await database.select(database.libraryEntries).getSingle()).favorite,
        isTrue,
      );
    },
  );

  test('query limits results to one tag', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(database, id: 'tagged', title: 'Tagged');
    await _insertMediaAndLibraryEntry(database, id: 'plain', title: 'Plain');
    await database.customStatement(
      "INSERT INTO tags (id, name, normalized_name, created_at) "
      "VALUES ('tag', '收藏', '收藏', 1)",
    );
    await database.customStatement(
      "INSERT INTO media_tag_assignments (tag_id, media_item_id, created_at) "
      "VALUES ('tag', 'tagged', 1)",
    );
    final query = const LibraryQuery().copyWith(
      tagId: 'tag',
      organizationLabel: '标签：收藏',
    );

    final items = await repository.watchLibrary(query).first;

    expect(items.map((item) => item.mediaItem.id), ['tagged']);
  });

  test('query limits results to one custom shelf', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(
      database,
      id: 'shelved',
      title: 'Shelved',
    );
    await _insertMediaAndLibraryEntry(database, id: 'plain', title: 'Plain');
    await database.customStatement(
      "INSERT INTO custom_shelves "
      "(id, name, normalized_name, created_at, updated_at) "
      "VALUES ('shelf', '待读', '待读', 1, 1)",
    );
    await database.customStatement(
      "INSERT INTO custom_shelf_items "
      "(shelf_id, media_item_id, order_index, added_at) "
      "VALUES ('shelf', 'shelved', 0, 1)",
    );
    final query = const LibraryQuery().copyWith(
      shelfId: 'shelf',
      organizationLabel: '书架：待读',
    );

    final items = await repository.watchLibrary(query).first;

    expect(items.map((item) => item.mediaItem.id), ['shelved']);
  });

  test('updates local metadata and clears optional blank fields', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(
      database,
      id: 'book',
      title: 'Old title',
      subtitle: 'Old subtitle',
      creator: 'Old author',
    );

    await repository.updateMetadata(
      mediaItemId: 'book',
      title: '  New title  ',
      subtitle: '   ',
      creator: ' New author ',
      description: ' Local description ',
      updatedAt: DateTime.utc(2026, 8, 22, 9),
    );

    final item = await repository.findMediaItem('book');
    expect(item?.title, 'New title');
    expect(item?.subtitle, isNull);
    expect(item?.creator, 'New author');
    expect(item?.description, 'Local description');
    expect(item?.mediaType, domain.MediaType.novel);
  });

  test('rejects a blank title without changing existing metadata', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftMediaLibraryRepository(database);
    await _insertMediaAndLibraryEntry(database, id: 'book', title: 'Original');

    await expectLater(
      repository.updateMetadata(
        mediaItemId: 'book',
        title: '   ',
        updatedAt: DateTime.utc(2026, 8, 22, 9),
      ),
      throwsArgumentError,
    );

    expect((await repository.findMediaItem('book'))?.title, 'Original');
  });
}

Future<void> _insertMediaAndLibraryEntry(
  AppDatabase database, {
  required String id,
  String? entryId,
  required String title,
  String mediaType = 'novel',
  String? subtitle,
  String? creator,
  bool favorite = false,
  DateTime? addedAt,
  DateTime? lastOpenedAt,
  DateTime? archivedAt,
}) async {
  await database
      .into(database.mediaItems)
      .insert(
        MediaItemsCompanion.insert(
          id: id,
          mediaType: mediaType,
          title: title,
          subtitle: Value(subtitle),
          creator: Value(creator),
          createdAt: _now,
          updatedAt: _now,
        ),
      );
  await database
      .into(database.libraryEntries)
      .insert(
        LibraryEntriesCompanion.insert(
          id: entryId ?? 'entry-$id',
          mediaItemId: id,
          favorite: favorite,
          addedAt: addedAt ?? _now,
          lastOpenedAt: Value(lastOpenedAt),
          archivedAt: Value(archivedAt),
        ),
      );
}
