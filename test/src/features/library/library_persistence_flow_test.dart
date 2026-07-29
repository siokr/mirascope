import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/library/application/library_actions_controller.dart';
import 'package:mirascope/src/features/library/application/library_providers.dart';
import 'package:mirascope/src/features/library/data/drift_media_library_repository.dart';
import 'package:mirascope/src/features/library/domain/library_item.dart';

import '../../core/database/database_test_support.dart';

void main() {
  test(
    'open archive restore and provider restart preserve library data',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final repository = DriftMediaLibraryRepository(database);
      final now = DateTime.utc(2026, 7, 29, 9);
      await _insertAggregate(
        database,
        id: 'older',
        title: 'Older',
        addedAt: now,
        sourcePath: r'C:\Books\older.txt',
      );
      await _insertAggregate(
        database,
        id: 'newer',
        title: 'Newer',
        addedAt: now.add(const Duration(hours: 1)),
        sourcePath: r'C:\Books\newer.txt',
      );
      final openedAt = now.add(const Duration(hours: 2));
      final firstContainer = _container(repository, openedAt);
      var firstContainerDisposed = false;
      addTearDown(() {
        if (!firstContainerDisposed) {
          firstContainer.dispose();
        }
      });

      expect(
        (await _readActive(firstContainer)).map((item) => item.mediaItem.id),
        ['newer', 'older'],
      );
      expect(
        await firstContainer
            .read(libraryActionsProvider.notifier)
            .open('older', onReady: () {}),
        LibraryActionResult.succeeded,
      );
      firstContainer.dispose();
      firstContainerDisposed = true;

      final restartedRepository = DriftMediaLibraryRepository(database);
      final restartedContainer = _container(restartedRepository, openedAt);
      addTearDown(restartedContainer.dispose);
      final afterRestart = await _readActive(restartedContainer);
      expect(afterRestart.map((item) => item.mediaItem.id), ['older', 'newer']);
      expect(afterRestart.first.libraryEntry.lastOpenedAt, openedAt);

      expect(
        await restartedContainer
            .read(libraryActionsProvider.notifier)
            .archive('older'),
        LibraryActionResult.succeeded,
      );
      expect(
        (await restartedRepository.watchActiveLibrary().first).map(
          (item) => item.mediaItem.id,
        ),
        ['newer'],
      );
      expect(
        (await restartedRepository.watchArchivedLibrary().first).map(
          (item) => item.mediaItem.id,
        ),
        ['older'],
      );

      expect(
        await restartedContainer
            .read(libraryActionsProvider.notifier)
            .restore('older'),
        LibraryActionResult.succeeded,
      );
      expect(
        (await restartedRepository.watchActiveLibrary().first).map(
          (item) => item.mediaItem.id,
        ),
        ['older', 'newer'],
      );
      expect(await database.select(database.mediaItems).get(), hasLength(2));
      final imports = await database.select(database.importRecords).get();
      expect(imports, hasLength(2));
      expect(imports.map((record) => record.sourcePath).toSet(), {
        r'C:\Books\older.txt',
        r'C:\Books\newer.txt',
      });
    },
  );
}

Future<List<LibraryItem>> _readActive(ProviderContainer container) {
  final completer = Completer<List<LibraryItem>>();
  late final ProviderSubscription<AsyncValue<List<LibraryItem>>> subscription;
  subscription = container.listen(
    activeLibraryProvider,
    (_, next) => next.when(
      data: (items) {
        if (!completer.isCompleted) {
          completer.complete(items);
        }
      },
      error: (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
      loading: () {},
    ),
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}

ProviderContainer _container(
  DriftMediaLibraryRepository repository,
  DateTime now,
) {
  return ProviderContainer(
    overrides: [
      mediaLibraryRepositoryProvider.overrideWithValue(repository),
      libraryClockProvider.overrideWithValue(() => now),
    ],
  );
}

Future<void> _insertAggregate(
  AppDatabase database, {
  required String id,
  required String title,
  required DateTime addedAt,
  required String sourcePath,
}) async {
  await database.transaction(() async {
    await database
        .into(database.mediaItems)
        .insert(
          MediaItemsCompanion.insert(
            id: id,
            mediaType: 'novel',
            title: title,
            createdAt: addedAt,
            updatedAt: addedAt,
          ),
        );
    await database
        .into(database.libraryEntries)
        .insert(
          LibraryEntriesCompanion.insert(
            id: 'entry-$id',
            mediaItemId: id,
            favorite: false,
            addedAt: addedAt,
          ),
        );
    await database
        .into(database.importRecords)
        .insert(
          ImportRecordsCompanion.insert(
            id: 'import-$id',
            mediaItemId: Value(id),
            sourcePath: sourcePath,
            sourceKind: 'txtFile',
            fileSize: 100,
            fingerprint: 'fingerprint-$id',
            status: 'completed',
            createdAt: addedAt,
          ),
        );
  });
}
