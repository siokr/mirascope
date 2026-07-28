import 'progress_write_result.dart';
import 'reading_progress.dart';

abstract interface class ReadingProgressRepository {
  Future<ReadingProgress?> findForMedia(String mediaItemId);

  Future<ProgressWriteResult> save(ReadingProgress progress);
}
