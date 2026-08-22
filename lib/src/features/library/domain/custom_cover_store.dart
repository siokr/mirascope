import 'dart:io';

abstract interface class CustomCoverStore {
  Future<String> replaceFromFile({
    required String mediaItemId,
    required String sourcePath,
  });

  Future<File?> resolve(String coverRef);

  Future<void> remove(String mediaItemId);
}
