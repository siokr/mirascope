import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/features/novel/data/drift_bookmark_repository.dart';
import 'package:mirascope/src/features/novel/domain/bookmark.dart' as domain;

void main() {
  late AppDatabase database;
  late DriftBookmarkRepository repository;

  setUp(() async {
    database = AppDatabase.inMemory();
    repository = DriftBookmarkRepository(database);
    await database.customStatement(
      'INSERT INTO media_items '
      '(id, media_type, title, created_at, updated_at) '
      "VALUES ('media-1', 'novel', 'Novel', 1, 1)",
    );
    await database.customStatement(
      'INSERT INTO content_units '
      '(id, media_item_id, unit_type, title, order_index, content_ref, '
      'source_locator, content_hash) '
      "VALUES ('chapter-1', 'media-1', 'chapter', '第一章', 0, "
      "'chapter-1.txt', 'chapter-1', 'hash-1')",
    );
  });

  tearDown(() => database.close());

  test('saves, lists, and soft-deletes a bookmark', () async {
    final createdAt = DateTime.utc(2026, 8, 9, 12);
    await repository.save(
      domain.Bookmark(
        id: 'bookmark-1',
        mediaItemId: 'media-1',
        contentUnitId: 'chapter-1',
        locator: 'char-v1:42',
        label: '第一章 · 20%',
        createdAt: createdAt,
      ),
    );

    final saved = await repository.findForMedia('media-1');
    expect(saved, hasLength(1));
    expect(saved.single.locator, 'char-v1:42');

    await repository.delete(
      'bookmark-1',
      createdAt.add(const Duration(days: 1)),
    );
    expect(await repository.findForMedia('media-1'), isEmpty);
    expect(
      (await database.select(database.bookmarks).getSingle()).deletedAt,
      isNotNull,
    );
  });

  test('rejects a content unit owned by another media item', () async {
    await database.customStatement(
      'INSERT INTO media_items '
      '(id, media_type, title, created_at, updated_at) '
      "VALUES ('media-2', 'novel', 'Other', 1, 1)",
    );

    await expectLater(
      repository.save(
        domain.Bookmark(
          id: 'bookmark-2',
          mediaItemId: 'media-2',
          contentUnitId: 'chapter-1',
          locator: 'char-v1:1',
          label: '非法书签',
          createdAt: DateTime.utc(2026),
        ),
      ),
      throwsArgumentError,
    );
  });
}
