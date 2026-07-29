import 'import_record.dart';
import 'txt_source_candidate.dart';

abstract interface class SourceRelocationRepository {
  Future<ImportRecord?> findLatestSourceForMedia(String mediaItemId);

  Future<void> markSourceMissing({
    required String importRecordId,
    required String mediaItemId,
  });

  Future<void> relocateMatchingSource({
    required String importRecordId,
    required String mediaItemId,
    required String expectedFingerprint,
    required TxtSourceCandidate candidate,
  });
}
