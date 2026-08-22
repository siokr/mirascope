import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../domain/library_statistics.dart';
import '../domain/reading_history_item.dart';

final recentReadingHistoryProvider = StreamProvider<List<ReadingHistoryItem>>((
  ref,
) {
  return ref.watch(readingHistoryRepositoryProvider).watchRecent();
});

final libraryStatisticsProvider = StreamProvider<LibraryStatistics>((ref) {
  return ref.watch(readingHistoryRepositoryProvider).watchStatistics();
});
