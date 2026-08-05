import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/epub_file_picker.dart';
import '../domain/epub_source_candidate.dart';
import '../domain/import_repository.dart';

sealed class EpubSourcePreparationResult {
  const EpubSourcePreparationResult();
}

final class EpubSourceCancelled extends EpubSourcePreparationResult {
  const EpubSourceCancelled();
}

final class EpubSourceReady extends EpubSourcePreparationResult {
  const EpubSourceReady(this.candidate);

  final EpubSourceCandidate candidate;
}

final class EpubSourceDuplicate extends EpubSourcePreparationResult {
  const EpubSourceDuplicate({
    required this.candidate,
    required this.mediaItemId,
  });

  final EpubSourceCandidate candidate;
  final String mediaItemId;
}

final class EpubSourceFailed extends EpubSourcePreparationResult {
  const EpubSourceFailed(this.failure);

  final AppFailure failure;
}

final class PrepareEpubSource {
  const PrepareEpubSource({
    required this.filePicker,
    required this.sourceInspector,
    required this.importRepository,
  });

  final EpubFilePicker filePicker;
  final EpubSourceInspector sourceInspector;
  final ImportRepository importRepository;

  Future<EpubSourcePreparationResult> call() async {
    try {
      final path = await filePicker.pickEpubFile();
      if (path == null) {
        return const EpubSourceCancelled();
      }

      final candidate = await sourceInspector.inspect(path);
      final existing = await importRepository.findCompletedByFingerprint(
        candidate.fingerprint,
      );
      if (existing != null) {
        return EpubSourceDuplicate(
          candidate: candidate,
          mediaItemId: existing.mediaItemId!,
        );
      }
      return EpubSourceReady(candidate);
    } on Object catch (error) {
      final failure = mapToAppFailure(
        error,
        fallback: AppErrorCode.storageFailed,
      );
      logAppWarning(failure.code, stage: 'prepare_epub_source');
      return EpubSourceFailed(failure);
    }
  }
}
