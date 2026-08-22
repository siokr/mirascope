import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/database_providers.dart';
import '../../importing/data/flutter_manga_thumbnail_encoder.dart';
import '../data/dart_io_custom_cover_store.dart';
import '../data/file_selector_cover_image_picker.dart';
import '../domain/cover_image_picker.dart';
import '../domain/custom_cover_store.dart';
import 'library_providers.dart';
import 'set_custom_cover.dart';

final coverImagePickerProvider = Provider<CoverImagePicker>((ref) {
  return const FileSelectorCoverImagePicker();
});

final customCoverStoreProvider = FutureProvider<CustomCoverStore>((ref) async {
  final support = await getApplicationSupportDirectory();
  return DartIoCustomCoverStore(
    Directory('${support.path}${Platform.pathSeparator}custom_covers'),
    const FlutterMangaThumbnailEncoder(),
  );
});

final setCustomCoverProvider = FutureProvider<SetCustomCover>((ref) async {
  return SetCustomCover(
    picker: ref.watch(coverImagePickerProvider),
    store: await ref.watch(customCoverStoreProvider.future),
    repository: ref.watch(mediaLibraryRepositoryProvider),
    clock: ref.watch(libraryClockProvider),
  );
});

final mediaCoverFileProvider = FutureProvider.autoDispose.family<File?, String>((
  ref,
  coverRef,
) async {
  if (coverRef.startsWith('custom/')) {
    final store = await ref.watch(customCoverStoreProvider.future);
    return store.resolve(coverRef);
  }
  final match = RegExp(
    r'^manga/([A-Za-z0-9_-]+)/cover\.png$',
  ).firstMatch(coverRef);
  if (match == null) return null;
  final support = await getApplicationSupportDirectory();
  final file = File(
    '${support.path}${Platform.pathSeparator}derived_manga'
    '${Platform.pathSeparator}content${Platform.pathSeparator}${match.group(1)}'
    '${Platform.pathSeparator}cover.png',
  );
  return await file.exists() ? file : null;
});
