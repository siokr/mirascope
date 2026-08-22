import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/library/application/set_custom_cover.dart';
import 'package:mirascope/src/features/library/domain/cover_image_picker.dart';
import 'package:mirascope/src/features/library/domain/custom_cover_store.dart';

import '../library_test_support.dart';

void main() {
  test('cancelled selection leaves storage and metadata unchanged', () async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    final store = _Store();
    final useCase = SetCustomCover(
      picker: const _Picker(null),
      store: store,
      repository: repository,
      clock: () => DateTime.utc(2026, 8, 22),
    );

    expect(await useCase('book'), SetCustomCoverResult.cancelled);
    expect(store.replacements, isEmpty);
    expect(repository.coverUpdates, isEmpty);
  });

  test(
    'copies selected image then updates the media cover reference',
    () async {
      final repository = FakeMediaLibraryRepository();
      addTearDown(repository.close);
      final store = _Store();
      final updatedAt = DateTime.utc(2026, 8, 22, 11);
      final useCase = SetCustomCover(
        picker: const _Picker('C:/selected.jpg'),
        store: store,
        repository: repository,
        clock: () => updatedAt,
      );

      expect(await useCase('book'), SetCustomCoverResult.succeeded);
      expect(store.replacements, [('book', 'C:/selected.jpg')]);
      expect(repository.coverUpdates.single.mediaItemId, 'book');
      expect(repository.coverUpdates.single.coverRef, 'custom/book/cover.png');
      expect(repository.coverUpdates.single.updatedAt, updatedAt);
    },
  );

  test('returns a stable failure when the selected image is invalid', () async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(repository.close);
    final useCase = SetCustomCover(
      picker: const _Picker('C:/broken.jpg'),
      store: _Store()..error = const FormatException('private details'),
      repository: repository,
      clock: () => DateTime.utc(2026, 8, 22),
    );

    expect(await useCase('book'), SetCustomCoverResult.failed);
    expect(repository.coverUpdates, isEmpty);
  });
}

final class _Picker implements CoverImagePicker {
  const _Picker(this.path);
  final String? path;

  @override
  Future<String?> pickImage() async => path;
}

final class _Store implements CustomCoverStore {
  final replacements = <(String, String)>[];
  Object? error;

  @override
  Future<String> replaceFromFile({
    required String mediaItemId,
    required String sourcePath,
  }) async {
    if (error case final value?) throw value;
    replacements.add((mediaItemId, sourcePath));
    return 'custom/$mediaItemId/cover.png';
  }

  @override
  Future<void> remove(String mediaItemId) async {}

  @override
  Future<File?> resolve(String coverRef) async => null;
}
