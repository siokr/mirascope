import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/features/history/data/drift_reading_history_repository.dart';

import '../../../core/database/database_test_support.dart';

void main() {
  test(
    'recent history excludes unopened and archived media and is newest first',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final dynamic repository = _historyRepository(database);
      await _insertMedia(database, id: 'older', openedAt: 20);
      await _insertMedia(database, id: 'newer', openedAt: 30);
      await _insertMedia(database, id: 'unopened');
      await _insertMedia(
        database,
        id: 'archived',
        openedAt: 40,
        archivedAt: 50,
      );

      final items =
          await repository.watchRecent(limit: 10).first as List<dynamic>;

      expect(items.map((item) => item.mediaItemId), ['newer', 'older']);
    },
  );

  test(
    'statistics count active media favorites types and saved progress',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final dynamic repository = _historyRepository(database);
      await _insertMedia(
        database,
        id: 'novel',
        favorite: true,
        withProgress: true,
      );
      await _insertMedia(database, id: 'manga', mediaType: 'manga');
      await _insertMedia(
        database,
        id: 'archived',
        archivedAt: 50,
        withProgress: true,
      );

      final stats = await repository.watchStatistics().first as dynamic;

      expect(stats.totalMedia, 2);
      expect(stats.startedMedia, 1);
      expect(stats.favoriteMedia, 1);
      expect(stats.novelMedia, 1);
      expect(stats.mangaMedia, 1);
    },
  );
}

DriftReadingHistoryRepository _historyRepository(AppDatabase database) =>
    DriftReadingHistoryRepository(database);

Future<void> _insertMedia(
  AppDatabase database, {
  required String id,
  String mediaType = 'novel',
  bool favorite = false,
  int? openedAt,
  int? archivedAt,
  bool withProgress = false,
}) async {
  await database.customStatement(
    'INSERT INTO media_items '
    '(id, media_type, title, created_at, updated_at) VALUES (?, ?, ?, 1, 1)',
    [id, mediaType, id],
  );
  await database.customStatement(
    'INSERT INTO library_entries '
    '(id, media_item_id, favorite, added_at, last_opened_at, archived_at) '
    'VALUES (?, ?, ?, 1, ?, ?)',
    ['entry-$id', id, favorite ? 1 : 0, openedAt, archivedAt],
  );
  if (!withProgress) return;
  await database.customStatement(
    'INSERT INTO content_units '
    '(id, media_item_id, unit_type, title, order_index, content_ref, '
    'source_locator, content_hash) VALUES (?, ?, ?, ?, 0, ?, ?, ?)',
    [
      'unit-$id',
      id,
      'chapter',
      'Chapter',
      'content-$id',
      'source-$id',
      'hash-$id',
    ],
  );
  await database.customStatement(
    'INSERT INTO reading_progress '
    '(id, media_item_id, content_unit_id, locator, fraction, updated_at, revision) '
    'VALUES (?, ?, ?, ?, 0.5, 10, 0)',
    ['progress-$id', id, 'unit-$id', 'paragraph:1'],
  );
}
