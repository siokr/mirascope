import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/import_record.dart';
import '../domain/source_relocation_repository.dart';
import '../domain/txt_file_picker.dart';
import '../domain/txt_source_candidate.dart';

sealed class SourceRelocationResult {
  const SourceRelocationResult();
}

final class SourceRelocationCancelled extends SourceRelocationResult {
  const SourceRelocationCancelled();
}

final class SourceRelocated extends SourceRelocationResult {
  const SourceRelocated(this.candidate);
  final TxtSourceCandidate candidate;
}

final class SourceChangeConfirmationRequired extends SourceRelocationResult {
  SourceChangeConfirmationRequired({
    required this.current,
    required this.candidate,
  }) : failure = AppFailure.fromCode(AppErrorCode.sourceChanged);

  final ImportRecord current;
  final TxtSourceCandidate candidate;
  final AppFailure failure;
}

final class SourceRelocationFailed extends SourceRelocationResult {
  const SourceRelocationFailed(this.failure);
  final AppFailure failure;
}

final class RelocateTxtSource {
  const RelocateTxtSource({
    required this.filePicker,
    required this.sourceInspector,
    required this.repository,
  });

  final TxtFilePicker filePicker;
  final TxtSourceInspector sourceInspector;
  final SourceRelocationRepository repository;

  Future<SourceRelocationResult> call(String mediaItemId) async {
    try {
      final current = await repository.findLatestSourceForMedia(mediaItemId);
      if (current == null) {
        return SourceRelocationFailed(
          AppFailure.fromCode(AppErrorCode.fileNotFound),
        );
      }
      final path = await filePicker.pickTxtFile();
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
      logAppWarning(failure.code, stage: 'relocate_txt_source');
      return SourceRelocationFailed(failure);
    }
  }
}
