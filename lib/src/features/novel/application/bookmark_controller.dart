import 'package:flutter/foundation.dart';

import '../../../core/ids/id_generator.dart';
import '../domain/bookmark.dart';
import '../domain/bookmark_repository.dart';

final class BookmarkController extends ChangeNotifier {
  BookmarkController({
    required this.mediaItemId,
    required this.repository,
    required this.idGenerator,
    required this.clock,
  });

  final String mediaItemId;
  final BookmarkRepository repository;
  final IdGenerator idGenerator;
  final DateTime Function() clock;
  List<Bookmark> bookmarks = const [];
  bool loading = true;
  String? errorMessage;

  Future<void> initialize() async => _reload();

  Future<void> add({
    required String contentUnitId,
    required String locator,
    required String label,
  }) async {
    try {
      await repository.save(
        Bookmark(
          id: idGenerator.newId(),
          mediaItemId: mediaItemId,
          contentUnitId: contentUnitId,
          locator: locator,
          label: label,
          createdAt: clock().toUtc(),
        ),
      );
      await _reload();
    } on Object {
      errorMessage = '无法添加书签';
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    await repository.delete(id, clock().toUtc());
    await _reload();
  }

  Future<void> _reload() async {
    try {
      bookmarks = await repository.findForMedia(mediaItemId);
      errorMessage = null;
    } on Object {
      errorMessage = '无法读取书签';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
