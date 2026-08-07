import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/library/application/library_actions_controller.dart';
import 'package:mirascope/src/features/library/application/library_providers.dart';
import 'package:mirascope/src/features/importing/application/importing_providers.dart';
import 'package:mirascope/src/features/importing/domain/derived_epub_store.dart';
import 'package:mirascope/src/features/importing/domain/epub_container.dart';
import 'package:mirascope/src/features/importing/domain/epub_semantic_content.dart';
import 'package:mirascope/src/features/importing/domain/parsed_epub.dart';

import '../library_test_support.dart';

final _localNow = DateTime(2026, 7, 29, 18, 30);

void main() {
  test('open stores injected UTC time and releases busy state', () async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    final container = _container(repository);
    addTearDown(container.dispose);
    final result = await container
        .read(libraryActionsProvider.notifier)
        .open('book-1');

    expect(result, LibraryActionResult.succeeded);
    expect(repository.openedAt['book-1'], _localNow.toUtc());
    expect(container.read(libraryActionsProvider), isEmpty);
  });

  test('open failure returns a stable result and does not navigate', () async {
    final repository = FakeMediaLibraryRepository()
      ..markOpenedError = StateError('private database details');
    addTearDown(repository.close);
    final container = _container(repository);
    addTearDown(container.dispose);
    final result = await container
        .read(libraryActionsProvider.notifier)
        .open('book-1');

    expect(result, LibraryActionResult.failed);
  });

  test('duplicate action for one media item is blocked', () async {
    final repository = FakeMediaLibraryRepository()
      ..archiveGate = Completer<void>();
    addTearDown(repository.close);
    final container = _container(repository);
    addTearDown(container.dispose);
    final controller = container.read(libraryActionsProvider.notifier);

    final first = controller.archive('book-1');
    await Future<void>.delayed(Duration.zero);
    final duplicate = await controller.restore('book-1');

    expect(duplicate, LibraryActionResult.busy);
    expect(container.read(libraryActionsProvider), {'book-1'});
    repository.archiveGate!.complete();
    expect(await first, LibraryActionResult.succeeded);
    expect(container.read(libraryActionsProvider), isEmpty);
  });

  test('different media items can run actions independently', () async {
    final repository = FakeMediaLibraryRepository()
      ..archiveGate = Completer<void>();
    addTearDown(repository.close);
    final container = _container(repository);
    addTearDown(container.dispose);
    final controller = container.read(libraryActionsProvider.notifier);

    final first = controller.archive('book-1');
    await Future<void>.delayed(Duration.zero);
    final second = await controller.restore('book-2');

    expect(second, LibraryActionResult.succeeded);
    expect(repository.restored, ['book-2']);
    repository.archiveGate!.complete();
    expect(await first, LibraryActionResult.succeeded);
  });

  test('archive and restore failures return stable results', () async {
    final repository = FakeMediaLibraryRepository()
      ..archiveError = StateError('archive private details')
      ..restoreError = StateError('restore private details');
    addTearDown(repository.close);
    final container = _container(repository);
    addTearDown(container.dispose);
    final controller = container.read(libraryActionsProvider.notifier);

    expect(await controller.archive('book-1'), LibraryActionResult.failed);
    expect(await controller.restore('book-2'), LibraryActionResult.failed);
  });

  test(
    'delete removes database aggregate then committed derived text',
    () async {
      final repository = FakeMediaLibraryRepository();
      final store = FakeDerivedTxtStore();
      addTearDown(repository.close);
      final container = _container(repository, store: store);
      addTearDown(container.dispose);

      final result = await container
          .read(libraryActionsProvider.notifier)
          .delete('book-1');

      expect(result, LibraryActionResult.succeeded);
      expect(repository.deleted, ['book-1']);
      expect(store.removedRefs, ['content/book-1.txt']);
    },
  );

  test('delete routes EPUB chapter refs to the EPUB store', () async {
    final repository = FakeMediaLibraryRepository(
      deletedContentRefs: const {
        'epub/book-1/chapters/00000.json',
        'epub/book-1/chapters/00001.json',
      },
    );
    final epubStore = _FakeDerivedEpubStore();
    addTearDown(repository.close);
    final container = _container(repository, epubStore: epubStore);
    addTearDown(container.dispose);

    final result = await container
        .read(libraryActionsProvider.notifier)
        .delete('book-1');

    expect(result, LibraryActionResult.succeeded);
    expect(epubStore.removedRefs, hasLength(2));
  });
}

ProviderContainer _container(
  FakeMediaLibraryRepository repository, {
  FakeDerivedTxtStore? store,
  _FakeDerivedEpubStore? epubStore,
}) {
  return ProviderContainer(
    overrides: [
      mediaLibraryRepositoryProvider.overrideWithValue(repository),
      libraryClockProvider.overrideWithValue(() => _localNow),
      if (store != null)
        derivedTxtStoreProvider.overrideWith((ref) async => store),
      if (epubStore != null)
        derivedEpubStoreProvider.overrideWith((ref) async => epubStore),
    ],
  );
}

final class _FakeDerivedEpubStore implements DerivedEpubStore {
  final removedRefs = <String>[];

  @override
  Future<void> removeCommittedRef(String contentRef) async {
    removedRefs.add(contentRef);
  }

  @override
  Future<void> removeCommitted(StagedDerivedEpub staged) async {}
  @override
  Future<void> discard(StagedDerivedEpub staged) async {}
  @override
  Future<void> promote(StagedDerivedEpub staged) async {}
  @override
  Future<StagedDerivedEpub> stage({
    required String mediaItemId,
    required ParsedEpub book,
    required List<EpubSemanticChapter> chapters,
    required EpubContainer container,
  }) => throw UnimplementedError();
}
