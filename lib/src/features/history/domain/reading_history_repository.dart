import 'library_statistics.dart';
import 'reading_history_item.dart';

abstract interface class ReadingHistoryRepository {
  Stream<List<ReadingHistoryItem>> watchRecent({int limit = 50});
  Stream<LibraryStatistics> watchStatistics();
}
