import '../domain/cover_image_picker.dart';
import '../domain/custom_cover_store.dart';
import '../domain/media_library_repository.dart';

enum SetCustomCoverResult { succeeded, cancelled, failed }

typedef CustomCoverClock = DateTime Function();

final class SetCustomCover {
  const SetCustomCover({
    required this.picker,
    required this.store,
    required this.repository,
    required this.clock,
  });

  final CoverImagePicker picker;
  final CustomCoverStore store;
  final MediaLibraryRepository repository;
  final CustomCoverClock clock;

  Future<SetCustomCoverResult> call(String mediaItemId) async {
    try {
      final sourcePath = await picker.pickImage();
      if (sourcePath == null) return SetCustomCoverResult.cancelled;
      final coverRef = await store.replaceFromFile(
        mediaItemId: mediaItemId,
        sourcePath: sourcePath,
      );
      await repository.updateCoverRef(
        mediaItemId: mediaItemId,
        coverRef: coverRef,
        updatedAt: clock().toUtc(),
      );
      return SetCustomCoverResult.succeeded;
    } on Object {
      return SetCustomCoverResult.failed;
    }
  }
}
