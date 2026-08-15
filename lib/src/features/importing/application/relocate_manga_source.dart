import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/import_record.dart';
import '../domain/manga_source.dart';
import '../domain/source_relocation_repository.dart';
import 'relocate_txt_source.dart';

final class RelocateMangaSource {
  const RelocateMangaSource({
    required this.sourcePicker,
    required this.sourceInspector,
    required this.repository,
  });
  final MangaSourcePicker sourcePicker;
  final MangaSourceInspector sourceInspector;
  final SourceRelocationRepository repository;

  Future<SourceRelocationResult> call(
    String mediaItemId,
    MangaSourceKind kind,
  ) async {
    try {
      final sourceKind = kind == MangaSourceKind.archive
          ? ImportSourceKind.mangaArchive
          : ImportSourceKind.mangaDirectory;
      final current = await repository.findLatestSourceForMedia(
        mediaItemId,
        sourceKind: sourceKind,
      );
      if (current == null) {
        return SourceRelocationFailed(
          AppFailure.fromCode(AppErrorCode.fileNotFound),
        );
      }
      final path = kind == MangaSourceKind.archive
          ? await sourcePicker.pickArchive()
          : await sourcePicker.pickDirectory();
      if (path == null) return const SourceRelocationCancelled();
      final candidate = await sourceInspector.inspect(
        MangaSourceSelection(path: path, kind: kind),
      );
      if (candidate.fingerprint != current.fingerprint) {
        return SourceChangeConfirmationRequired(
          current: current,
          candidate: candidate,
        );
      }
      await repository.relocateMatchingSource(
        importRecordId: current.id,
        mediaItemId: mediaItemId,
        expectedFingerprint: current.fingerprint,
        candidate: candidate,
      );
      return SourceRelocated(candidate);
    } on Object catch (error) {
      final failure = mapToAppFailure(
        error,
        fallback: AppErrorCode.storageFailed,
      );
      logAppWarning(failure.code, stage: 'relocate_manga_source');
      return SourceRelocationFailed(failure);
    }
  }
}
