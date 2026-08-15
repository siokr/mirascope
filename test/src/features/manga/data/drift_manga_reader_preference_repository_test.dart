import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart'
    show MediaItemsCompanion;
import 'package:mirascope/src/features/manga/data/drift_manga_reader_preference_repository.dart';
import 'package:mirascope/src/features/manga/domain/manga_reader_preference.dart';

import '../../../core/database/database_test_support.dart';

void main() {
  test('upserts preference and rejects an older asynchronous value', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final now = DateTime.utc(2026, 8, 15, 12);
    await database
        .into(database.mediaItems)
        .insert(
          MediaItemsCompanion.insert(
            id: 'media',
            mediaType: 'manga',
            title: '漫画',
            createdAt: now,
            updatedAt: now,
          ),
        );
    final repository = DriftMangaReaderPreferenceRepository(database);
    await repository.save(
      MangaReaderPreference(
        id: 'new',
        mediaItemId: 'media',
        readingMode: MangaReadingMode.horizontal,
        pageTurnDirection: PageTurnDirection.rightToLeft,
        updatedAt: now,
      ),
    );
    await repository.save(
      MangaReaderPreference(
        id: 'old',
        mediaItemId: 'media',
        readingMode: MangaReadingMode.vertical,
        pageTurnDirection: PageTurnDirection.leftToRight,
        updatedAt: now.subtract(const Duration(minutes: 1)),
      ),
    );
    final value = await repository.findForMedia('media');
    expect(value?.id, 'new');
    expect(value?.readingMode, MangaReadingMode.horizontal);
    expect(value?.pageTurnDirection, PageTurnDirection.rightToLeft);
  });
}
