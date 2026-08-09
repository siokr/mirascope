import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/importing/data/drift_import_repository.dart';
import 'package:mirascope/src/features/library/data/drift_media_library_repository.dart';
import 'package:mirascope/src/features/novel/data/drift_reading_progress_repository.dart';
import 'package:mirascope/src/features/novel/data/drift_bookmark_repository.dart';
import 'package:mirascope/src/features/novel/data/drift_novel_details_repository.dart';
import 'package:mirascope/src/features/settings/data/drift_reader_preference_repository.dart';

void main() {
  test('database provider returns the injected in-memory instance', () async {
    final database = AppDatabase.inMemory();
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);

    expect(container.read(appDatabaseProvider), same(database));
  });

  test('repository providers construct the six Drift repositories', () async {
    final database = AppDatabase.inMemory();
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);

    final mediaLibrary = container.read(mediaLibraryRepositoryProvider);
    final readingProgress = container.read(readingProgressRepositoryProvider);
    final novelDetails = container.read(novelDetailsRepositoryProvider);
    final readerPreference = container.read(readerPreferenceRepositoryProvider);
    final importing = container.read(importRepositoryProvider);
    final bookmarks = container.read(bookmarkRepositoryProvider);

    expect(mediaLibrary, isA<DriftMediaLibraryRepository>());
    expect(
      (mediaLibrary as DriftMediaLibraryRepository).database,
      same(database),
    );
    expect(readingProgress, isA<DriftReadingProgressRepository>());
    expect(
      (readingProgress as DriftReadingProgressRepository).database,
      same(database),
    );
    expect(novelDetails, isA<DriftNovelDetailsRepository>());
    expect(
      (novelDetails as DriftNovelDetailsRepository).database,
      same(database),
    );
    expect(readerPreference, isA<DriftReaderPreferenceRepository>());
    expect(
      (readerPreference as DriftReaderPreferenceRepository).database,
      same(database),
    );
    expect(importing, isA<DriftImportRepository>());
    expect((importing as DriftImportRepository).database, same(database));
    expect(bookmarks, isA<DriftBookmarkRepository>());
    expect((bookmarks as DriftBookmarkRepository).database, same(database));
  });
}
