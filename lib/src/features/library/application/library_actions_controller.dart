import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/errors/app_error_code.dart';
import '../../../core/logging/app_logger.dart';
import '../../importing/application/importing_providers.dart';
import 'library_providers.dart';

enum LibraryActionResult { succeeded, busy, failed }

final libraryActionsProvider =
    NotifierProvider<LibraryActionsController, Set<String>>(
      LibraryActionsController.new,
    );

final class LibraryActionsController extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  Future<LibraryActionResult> open(String mediaItemId) {
    return _run(
      mediaItemId,
      failureCode: AppErrorCode.libraryOpenFailed,
      operation: () async {
        final openedAt = ref.read(libraryClockProvider)().toUtc();
        await ref
            .read(mediaLibraryRepositoryProvider)
            .markOpened(mediaItemId, openedAt);
      },
    );
  }

  Future<LibraryActionResult> archive(String mediaItemId) {
    return _run(
      mediaItemId,
      failureCode: AppErrorCode.libraryArchiveFailed,
      operation: () {
        final archivedAt = ref.read(libraryClockProvider)().toUtc();
        return ref
            .read(mediaLibraryRepositoryProvider)
            .archive(mediaItemId, archivedAt);
      },
    );
  }

  Future<LibraryActionResult> setFavorite(String mediaItemId, bool favorite) {
    return _run(
      mediaItemId,
      failureCode: AppErrorCode.libraryLoadFailed,
      operation: () => ref
          .read(mediaLibraryRepositoryProvider)
          .setFavorite(mediaItemId, favorite),
    );
  }

  Future<LibraryActionResult> restore(String mediaItemId) {
    return _run(
      mediaItemId,
      failureCode: AppErrorCode.libraryRestoreFailed,
      operation: () =>
          ref.read(mediaLibraryRepositoryProvider).restore(mediaItemId),
    );
  }

  Future<LibraryActionResult> delete(String mediaItemId) {
    return _run(
      mediaItemId,
      failureCode: AppErrorCode.libraryDeleteFailed,
      operation: () async {
        final contentRefs = await ref
            .read(mediaLibraryRepositoryProvider)
            .deleteApplicationData(mediaItemId);
        try {
          for (final contentRef in contentRefs) {
            if (contentRef.startsWith('epub/')) {
              final epubStore = await ref.read(derivedEpubStoreProvider.future);
              await epubStore.removeCommittedRef(contentRef);
            } else if (contentRef.startsWith('manga/')) {
              final mangaStore = await ref.read(
                derivedMangaStoreProvider.future,
              );
              await mangaStore.removeCommittedRef(contentRef);
            } else {
              final txtStore = await ref.read(derivedTxtStoreProvider.future);
              await txtStore.removeCommittedRef(contentRef);
            }
          }
        } on Object {
          logAppWarning(
            AppErrorCode.libraryDeleteFailed.value,
            stage: 'derived_cleanup',
          );
        }
      },
    );
  }

  Future<LibraryActionResult> _run(
    String mediaItemId, {
    required AppErrorCode failureCode,
    required Future<void> Function() operation,
  }) async {
    if (state.contains(mediaItemId)) {
      return LibraryActionResult.busy;
    }

    state = Set.unmodifiable({...state, mediaItemId});
    try {
      await operation();
      return LibraryActionResult.succeeded;
    } on Object {
      logAppWarning(failureCode.value, stage: 'library_action');
      return LibraryActionResult.failed;
    } finally {
      final remaining = {...state}..remove(mediaItemId);
      state = Set.unmodifiable(remaining);
    }
  }
}
