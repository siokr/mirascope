import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../library/domain/media_item.dart';
import '../domain/library_statistics.dart';
import '../domain/reading_history_item.dart';
import '../domain/reading_history_repository.dart';

final class DriftReadingHistoryRepository implements ReadingHistoryRepository {
  DriftReadingHistoryRepository(this.database);

  final AppDatabase database;

  @override
  Stream<List<ReadingHistoryItem>> watchRecent({int limit = 50}) {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'must be positive');
    }
    return database
        .customSelect(
          'SELECT m.id, m.title, m.media_type, m.cover_ref, '
          'le.last_opened_at, rp.updated_at AS progress_updated_at, rp.fraction '
          'FROM library_entries le '
          'JOIN media_items m ON m.id = le.media_item_id '
          'LEFT JOIN reading_progress rp ON rp.media_item_id = m.id '
          'WHERE le.archived_at IS NULL AND le.last_opened_at IS NOT NULL '
          'ORDER BY le.last_opened_at DESC, le.id ASC LIMIT ?',
          variables: [Variable.withInt(limit)],
          readsFrom: {
            database.libraryEntries,
            database.mediaItems,
            database.readingProgressEntries,
          },
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => ReadingHistoryItem(
                  mediaItemId: row.read<String>('id'),
                  title: row.read<String>('title'),
                  mediaType: MediaType.fromStorageValue(
                    row.read<String>('media_type'),
                  ),
                  coverRef: row.readNullable<String>('cover_ref'),
                  lastOpenedAt: _date(row.read<int>('last_opened_at')),
                  progressUpdatedAt: _nullableDate(
                    row.readNullable<int>('progress_updated_at'),
                  ),
                  fraction: row.readNullable<double>('fraction'),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Stream<LibraryStatistics> watchStatistics() {
    return database
        .customSelect(
          'SELECT COUNT(*) AS total_media, '
          'COALESCE(SUM(CASE WHEN rp.media_item_id IS NOT NULL THEN 1 ELSE 0 END), 0) '
          'AS started_media, '
          'COALESCE(SUM(CASE WHEN le.favorite = 1 THEN 1 ELSE 0 END), 0) '
          'AS favorite_media, '
          "COALESCE(SUM(CASE WHEN m.media_type = 'novel' THEN 1 ELSE 0 END), 0) "
          'AS novel_media, '
          "COALESCE(SUM(CASE WHEN m.media_type = 'manga' THEN 1 ELSE 0 END), 0) "
          'AS manga_media '
          'FROM library_entries le '
          'JOIN media_items m ON m.id = le.media_item_id '
          'LEFT JOIN reading_progress rp ON rp.media_item_id = m.id '
          'WHERE le.archived_at IS NULL',
          readsFrom: {
            database.libraryEntries,
            database.mediaItems,
            database.readingProgressEntries,
          },
        )
        .watchSingle()
        .map(
          (row) => LibraryStatistics(
            totalMedia: row.read<int>('total_media'),
            startedMedia: row.read<int>('started_media'),
            favoriteMedia: row.read<int>('favorite_media'),
            novelMedia: row.read<int>('novel_media'),
            mangaMedia: row.read<int>('manga_media'),
          ),
        );
  }

  DateTime _date(int milliseconds) =>
      DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);

  DateTime? _nullableDate(int? milliseconds) =>
      milliseconds == null ? null : _date(milliseconds);
}
