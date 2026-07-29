import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/library/application/library_providers.dart';
import 'package:mirascope/src/features/library/domain/library_entry.dart';
import 'package:mirascope/src/features/library/domain/library_item.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';

import '../library_test_support.dart';

void main() {
  test(
    'library providers forward active and archived repository streams',
    () async {
      final repository = FakeMediaLibraryRepository();
      addTearDown(repository.close);
      final container = ProviderContainer(
        overrides: [
          mediaLibraryRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final active = Completer<List<LibraryItem>>();
      final archived = Completer<List<LibraryItem>>();
      final activeSubscription = container.listen(
        activeLibraryProvider,
        (_, next) => next.whenData((value) {
          if (!active.isCompleted) {
            active.complete(value);
          }
        }),
      );
      final archivedSubscription = container.listen(
        archivedLibraryProvider,
        (_, next) => next.whenData((value) {
          if (!archived.isCompleted) {
            archived.complete(value);
          }
        }),
      );
      addTearDown(activeSubscription.close);
      addTearDown(archivedSubscription.close);
      final activeItem = _item('active');
      final archivedItem = _item('archived');

      await Future<void>.delayed(Duration.zero);
      repository.activeController.add([activeItem]);
      repository.archivedController.add([archivedItem]);

      expect(await active.future, [activeItem]);
      expect(await archived.future, [archivedItem]);
    },
  );
}

LibraryItem _item(String id) {
  final now = DateTime.utc(2026, 7, 29);
  return LibraryItem(
    mediaItem: MediaItem(
      id: id,
      mediaType: MediaType.novel,
      title: id,
      createdAt: now,
      updatedAt: now,
    ),
    libraryEntry: LibraryEntry(
      id: 'entry-$id',
      mediaItemId: id,
      favorite: false,
      addedAt: now,
    ),
  );
}
