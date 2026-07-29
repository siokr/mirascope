import 'dart:async';

import 'package:mirascope/src/features/library/domain/library_item.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/library/domain/media_library_repository.dart';

final class FakeMediaLibraryRepository implements MediaLibraryRepository {
  final activeController = StreamController<List<LibraryItem>>.broadcast();
  final archivedController = StreamController<List<LibraryItem>>.broadcast();

  final openedAt = <String, DateTime>{};
  final archivedAt = <String, DateTime>{};
  final restored = <String>[];
  final deleted = <String>[];
  var activeWatchCount = 0;
  var archivedWatchCount = 0;

  Completer<void>? markOpenedGate;
  Completer<void>? archiveGate;
  Completer<void>? restoreGate;
  Object? markOpenedError;
  Object? archiveError;
  Object? restoreError;

  Future<void> close() async {
    await activeController.close();
    await archivedController.close();
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
  Future<void> deleteApplicationData(String mediaItemId) async {
    deleted.add(mediaItemId);
  }
}
