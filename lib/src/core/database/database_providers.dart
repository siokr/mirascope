import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/importing/data/drift_import_repository.dart';
import '../../features/importing/domain/import_repository.dart';
import '../../features/importing/domain/source_relocation_repository.dart';
import '../../features/library/data/drift_media_library_repository.dart';
import '../../features/library/domain/media_library_repository.dart';
import '../../features/novel/data/drift_reading_progress_repository.dart';
import '../../features/novel/data/drift_bookmark_repository.dart';
import '../../features/novel/domain/bookmark_repository.dart';
import '../../features/novel/data/drift_novel_details_repository.dart';
import '../../features/novel/domain/novel_details_repository.dart';
import '../../features/novel/domain/reading_progress_repository.dart';
import '../../features/settings/data/drift_reader_preference_repository.dart';
import '../../features/settings/domain/reader_preference_repository.dart';
import 'app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw StateError('AppDatabase has not been initialized');
});

final mediaLibraryRepositoryProvider = Provider<MediaLibraryRepository>((ref) {
  return DriftMediaLibraryRepository(ref.watch(appDatabaseProvider));
});

final readingProgressRepositoryProvider = Provider<ReadingProgressRepository>((
  ref,
) {
  return DriftReadingProgressRepository(ref.watch(appDatabaseProvider));
});

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return DriftBookmarkRepository(ref.watch(appDatabaseProvider));
});

final novelDetailsRepositoryProvider = Provider<NovelDetailsRepository>((ref) {
  return DriftNovelDetailsRepository(ref.watch(appDatabaseProvider));
});

final readerPreferenceRepositoryProvider = Provider<ReaderPreferenceRepository>(
  (ref) {
    return DriftReaderPreferenceRepository(ref.watch(appDatabaseProvider));
  },
);

final importRepositoryProvider = Provider<ImportRepository>((ref) {
  return DriftImportRepository(ref.watch(appDatabaseProvider));
});

final sourceRelocationRepositoryProvider = Provider<SourceRelocationRepository>(
  (ref) {
    return DriftImportRepository(ref.watch(appDatabaseProvider));
  },
);
