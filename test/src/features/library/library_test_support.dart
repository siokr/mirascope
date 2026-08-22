import 'dart:async';

import 'package:mirascope/src/features/library/domain/library_item.dart';
import 'package:mirascope/src/features/library/domain/library_query.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/library/domain/media_library_repository.dart';
import 'package:mirascope/src/features/importing/domain/derived_txt_store.dart';

final class FakeMediaLibraryRepository implements MediaLibraryRepository {
  FakeMediaLibraryRepository({this.deletedContentRefs});

  final Set<String>? deletedContentRefs;
  final activeController = StreamController<List<LibraryItem>>.broadcast();
  final archivedController = StreamController<List<LibraryItem>>.broadcast();

  final openedAt = <String, DateTime>{};
  final favoriteValues = <String, bool>{};
  final metadataUpdates = <MetadataUpdate>[];
  final coverUpdates = <CoverUpdate>[];
  final archivedAt = <String, DateTime>{};
  final restored = <String>[];
  final deleted = <String>[];
  var activeWatchCount = 0;
  var archivedWatchCount = 0;
  LibraryQuery? lastQuery;

  Completer<void>? markOpenedGate;
  Completer<void>? archiveGate;
  Completer<void>? restoreGate;
  Object? markOpenedError;
  Object? archiveError;
  Object? restoreError;
  Object? deleteError;

  Future<void> close() async {
    await activeController.close();
    await archivedController.close();
  }

  @override
  Stream<List<LibraryItem>> watchLibrary(LibraryQuery query) {
    lastQuery = query;
    if (query.archived) {
      archivedWatchCount += 1;
      return archivedController.stream;
    }
    activeWatchCount += 1;
    return activeController.stream;
  }

  @override
  Stream<List<LibraryItem>> watchActiveLibrary() {
    activeWatchCount += 1;
    return activeController.stream;
  }

  @override
  Stream<List<LibraryItem>> watchArchivedLibrary() {
    archivedWatchCount += 1;
    return archivedController.stream;
  }

  @override
  Future<MediaItem?> findMediaItem(String mediaItemId) async => null;

  @override
  Future<void> markOpened(String mediaItemId, DateTime openedAt) async {
    if (markOpenedError case final error?) {
      throw error;
    }
    this.openedAt[mediaItemId] = openedAt;
    await markOpenedGate?.future;
  }

  @override
  Future<void> setFavorite(String mediaItemId, bool favorite) async {
    favoriteValues[mediaItemId] = favorite;
  }

  @override
  Future<void> updateMetadata({
    required String mediaItemId,
    required String title,
    String? subtitle,
    String? creator,
    String? description,
    required DateTime updatedAt,
  }) async {
    metadataUpdates.add(
      MetadataUpdate(
        mediaItemId: mediaItemId,
        title: title,
        subtitle: subtitle,
        creator: creator,
        description: description,
        updatedAt: updatedAt,
      ),
    );
  }

  @override
  Future<void> updateCoverRef({
    required String mediaItemId,
    required String coverRef,
    required DateTime updatedAt,
  }) async {
    coverUpdates.add(
      CoverUpdate(
        mediaItemId: mediaItemId,
        coverRef: coverRef,
        updatedAt: updatedAt,
      ),
    );
  }

  @override
  Future<void> archive(String mediaItemId, DateTime archivedAt) async {
    if (archiveError case final error?) {
      throw error;
    }
    this.archivedAt[mediaItemId] = archivedAt;
    await archiveGate?.future;
  }

  @override
  Future<void> restore(String mediaItemId) async {
    if (restoreError case final error?) {
      throw error;
    }
    restored.add(mediaItemId);
    await restoreGate?.future;
  }

  @override
  Future<Set<String>> deleteApplicationData(String mediaItemId) async {
    if (deleteError case final error?) {
      throw error;
    }
    deleted.add(mediaItemId);
    return deletedContentRefs ?? {'content/$mediaItemId.txt'};
  }
}

final class MetadataUpdate {
  const MetadataUpdate({
    required this.mediaItemId,
    required this.title,
    required this.subtitle,
    required this.creator,
    required this.description,
    required this.updatedAt,
  });

  final String mediaItemId;
  final String title;
  final String? subtitle;
  final String? creator;
  final String? description;
  final DateTime updatedAt;
}

final class CoverUpdate {
  const CoverUpdate({
    required this.mediaItemId,
    required this.coverRef,
    required this.updatedAt,
  });

  final String mediaItemId;
  final String coverRef;
  final DateTime updatedAt;
}

final class FakeDerivedTxtStore implements DerivedTxtStore {
  final removedRefs = <String>[];

  @override
  Future<void> removeCommittedRef(String contentRef) async {
    removedRefs.add(contentRef);
  }

  @override
  Future<void> removeCommitted(StagedDerivedTxt staged) =>
      removeCommittedRef(staged.contentRef);

  @override
  Future<void> discard(StagedDerivedTxt staged) async {}

  @override
  Future<void> promote(StagedDerivedTxt staged) async {}

  @override
  Future<StagedDerivedTxt> stage({
    required String mediaItemId,
    required String text,
  }) async => StagedDerivedTxt(
    contentRef: 'content/$mediaItemId.txt',
    temporaryToken: 'temporary',
  );
}
