import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/import_repository.dart';
import '../domain/manga_source.dart';

sealed class MangaSourcePreparationResult {
  const MangaSourcePreparationResult();
}

final class MangaSourceCancelled extends MangaSourcePreparationResult {
  const MangaSourceCancelled();
}

final class MangaSourceReady extends MangaSourcePreparationResult {
  const MangaSourceReady(this.candidate);

  final MangaSourceCandidate candidate;
}

final class MangaSourceDuplicate extends MangaSourcePreparationResult {
  const MangaSourceDuplicate({
    required this.candidate,
    required this.mediaItemId,
  });

  final MangaSourceCandidate candidate;
  final String mediaItemId;
}

final class MangaSourceFailed extends MangaSourcePreparationResult {
  const MangaSourceFailed(this.failure);

  final AppFailure failure;
}

final class PrepareMangaSource {
  const PrepareMangaSource({
    required this.sourcePicker,
    required this.sourceInspector,
    required this.importRepository,
  });

  final MangaSourcePicker sourcePicker;
  final MangaSourceInspector sourceInspector;
  final ImportRepository importRepository;

  Future<MangaSourcePreparationResult> call(MangaSourceKind kind) async {
    try {
      final path = switch (kind) {
        MangaSourceKind.archive => await sourcePicker.pickArchive(),
        MangaSourceKind.directory => await sourcePicker.pickDirectory(),
      };
      if (path == null) {
        return const MangaSourceCancelled();
      }
      final candidate = await sourceInspector.inspect(
        MangaSourceSelection(path: path, kind: kind),
      );
      final existing = await importRepository.findCompletedByFingerprint(
        candidate.fingerprint,
      );
      if (existing != null) {
        return MangaSourceDuplicate(
          candidate: candidate,
          mediaItemId: existing.mediaItemId!,
        );
      }
      return MangaSourceReady(candidate);
    } on Object catch (error) {
      final failure = mapToAppFailure(
        error,
        fallback: AppErrorCode.storageFailed,
      );
      logAppWarning(failure.code, stage: 'prepare_manga_source');
      return MangaSourceFailed(failure);
    }
  }
}
