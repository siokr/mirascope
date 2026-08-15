import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/manga_reader_preference.dart' as domain;
import '../domain/manga_reader_preference_repository.dart';

final class DriftMangaReaderPreferenceRepository
    implements MangaReaderPreferenceRepository {
  const DriftMangaReaderPreferenceRepository(this.database);
  final AppDatabase database;

  @override
  Future<domain.MangaReaderPreference?> findForMedia(String mediaItemId) async {
    final row =
        await (database.select(database.mangaReaderPreferences)
              ..where((value) => value.mediaItemId.equals(mediaItemId)))
            .getSingleOrNull();
    return row == null
        ? null
        : domain.MangaReaderPreference(
            id: row.id,
            mediaItemId: row.mediaItemId,
            readingMode: domain.MangaReadingMode.fromStorageValue(
              row.readingMode,
            ),
            pageTurnDirection: domain.PageTurnDirection.fromStorageValue(
              row.pageTurnDirection,
            ),
            updatedAt: row.updatedAt,
          );
  }

  @override
  Future<void> save(domain.MangaReaderPreference preference) async {
    await database.customUpdate(
      'INSERT INTO manga_reader_preferences '
      '(id, media_item_id, reading_mode, page_turn_direction, updated_at) '
      'VALUES (?, ?, ?, ?, ?) ON CONFLICT(media_item_id) DO UPDATE SET '
      'id = excluded.id, reading_mode = excluded.reading_mode, '
      'page_turn_direction = excluded.page_turn_direction, updated_at = excluded.updated_at '
      'WHERE excluded.updated_at >= manga_reader_preferences.updated_at',
      variables: [
        Variable.withString(preference.id),
        Variable.withString(preference.mediaItemId),
        Variable.withString(preference.readingMode.storageValue),
        Variable.withString(preference.pageTurnDirection.storageValue),
        Variable.withInt(preference.updatedAt.toUtc().millisecondsSinceEpoch),
      ],
      updates: {database.mangaReaderPreferences},
    );
  }
}
