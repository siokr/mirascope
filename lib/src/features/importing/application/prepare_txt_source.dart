import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/import_repository.dart';
import '../domain/txt_file_picker.dart';
import '../domain/txt_source_candidate.dart';

sealed class TxtSourcePreparationResult {
  const TxtSourcePreparationResult();
}

final class TxtSourceCancelled extends TxtSourcePreparationResult {
  const TxtSourceCancelled();
}

final class TxtSourceReady extends TxtSourcePreparationResult {
  const TxtSourceReady(this.candidate);

  final TxtSourceCandidate candidate;
}

final class TxtSourceDuplicate extends TxtSourcePreparationResult {
  const TxtSourceDuplicate({
    required this.candidate,
    required this.mediaItemId,
  });

  final TxtSourceCandidate candidate;
  final String mediaItemId;
}

final class TxtSourceFailed extends TxtSourcePreparationResult {
  const TxtSourceFailed(this.failure);

  final AppFailure failure;
}

final class PrepareTxtSource {
  const PrepareTxtSource({
    required this.filePicker,
    required this.sourceInspector,
    required this.importRepository,
  });

  final TxtFilePicker filePicker;
  final TxtSourceInspector sourceInspector;
  final ImportRepository importRepository;

  Future<TxtSourcePreparationResult> call() async {
    try {
      final path = await filePicker.pickTxtFile();
      if (path == null) {
        return const TxtSourceCancelled();
      }

      final candidate = await sourceInspector.inspect(path);
      final existing = await importRepository.findCompletedByFingerprint(
        candidate.fingerprint,
      );
      if (existing != null) {
        return TxtSourceDuplicate(
          candidate: candidate,
          mediaItemId: existing.mediaItemId!,
        );
      }
      return TxtSourceReady(candidate);
    } on Object catch (error) {
      final failure = mapToAppFailure(
        error,
        fallback: AppErrorCode.storageFailed,
      );
      logAppWarning(failure.code, stage: 'prepare_txt_source');
      return TxtSourceFailed(failure);
    }
  }
}
