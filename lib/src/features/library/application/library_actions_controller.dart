import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/logging/app_logger.dart';
import 'library_providers.dart';

enum LibraryActionResult { succeeded, busy, failed }

final libraryActionsProvider =
    NotifierProvider<LibraryActionsController, Set<String>>(
      LibraryActionsController.new,
    );

final class LibraryActionsController extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  Future<LibraryActionResult> open(
    String mediaItemId, {
    required FutureOr<void> Function() onReady,
  }) {
    return _run(
      mediaItemId,
      failureCode: 'library_open_failed',
      operation: () async {
        final openedAt = ref.read(libraryClockProvider)().toUtc();
        await ref
            .read(mediaLibraryRepositoryProvider)
            .markOpened(mediaItemId, openedAt);
        await onReady();
      },
    );
  }

  Future<LibraryActionResult> archive(String mediaItemId) {
    return _run(
      mediaItemId,
      failureCode: 'library_archive_failed',
      operation: () {
        final archivedAt = ref.read(libraryClockProvider)().toUtc();
        return ref
            .read(mediaLibraryRepositoryProvider)
            .archive(mediaItemId, archivedAt);
      },
    );
  }

  Future<LibraryActionResult> restore(String mediaItemId) {
    return _run(
      mediaItemId,
      failureCode: 'library_restore_failed',
      operation: () =>
          ref.read(mediaLibraryRepositoryProvider).restore(mediaItemId),
    );
  }

  Future<LibraryActionResult> _run(
    String mediaItemId, {
    required String failureCode,
    required FutureOr<void> Function() operation,
  }) async {
    if (state.contains(mediaItemId)) {
      return LibraryActionResult.busy;
    }

    state = Set.unmodifiable({...state, mediaItemId});
    try {
      await operation();
      return LibraryActionResult.succeeded;
    } on Object {
      appLogger.warning(failureCode);
      return LibraryActionResult.failed;
    } finally {
      final remaining = {...state}..remove(mediaItemId);
      state = Set.unmodifiable(remaining);
    }
  }
}
