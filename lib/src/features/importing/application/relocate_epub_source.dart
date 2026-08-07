import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/epub_file_picker.dart';
import '../domain/epub_source_candidate.dart';
import '../domain/import_record.dart';
import '../domain/source_relocation_repository.dart';
import 'relocate_txt_source.dart';

final class RelocateEpubSource {
  const RelocateEpubSource({
    required this.filePicker,
    required this.sourceInspector,
    required this.repository,
  });

  final EpubFilePicker filePicker;
  final EpubSourceInspector sourceInspector;
  final SourceRelocationRepository repository;

  Future<SourceRelocationResult> call(String mediaItemId) async {
    try {
      final current = await repository.findLatestSourceForMedia(
        mediaItemId,
        sourceKind: ImportSourceKind.epubFile,
      );
      if (current == null) {
        return SourceRelocationFailed(
          AppFailure.fromCode(AppErrorCode.fileNotFound),
        );
      }
      final path = await filePicker.pickEpubFile();
      if (path == null) return const SourceRelocationCancelled();
      final candidate = await sourceInspector.inspect(path);
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
      logAppWarning(failure.code, stage: 'relocate_epub_source');
      return SourceRelocationFailed(failure);
    }
  }
}
