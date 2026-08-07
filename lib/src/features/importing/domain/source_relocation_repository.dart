import 'import_record.dart';
import 'source_candidate.dart';

abstract interface class SourceRelocationRepository {
  Future<ImportRecord?> findLatestSourceForMedia(
    String mediaItemId, {
    ImportSourceKind sourceKind = ImportSourceKind.txtFile,
  });

  Future<void> markSourceMissing({
    required String importRecordId,
    required String mediaItemId,
  });

  Future<void> relocateMatchingSource({
    required String importRecordId,
    required String mediaItemId,
    required String expectedFingerprint,
    required SourceCandidate candidate,
  });
}
