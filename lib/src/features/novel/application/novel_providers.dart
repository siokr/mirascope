import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/database_providers.dart';
import '../data/dart_io_novel_reader_repository.dart';
import '../domain/novel_details.dart';
import '../domain/novel_reader_repository.dart';
import 'novel_reader_controller.dart';

final novelDetailsProvider = FutureProvider.autoDispose
    .family<NovelDetails?, String>((ref, mediaItemId) {
      return ref.watch(novelDetailsRepositoryProvider).findDetails(mediaItemId);
    });

final novelReaderRepositoryProvider = FutureProvider<NovelReaderRepository>((
  ref,
) async {
  final supportDirectory = await getApplicationSupportDirectory();
  return DartIoNovelReaderRepository(
    ref.watch(appDatabaseProvider),
    Directory('${supportDirectory.path}${Platform.pathSeparator}derived_txt'),
  );
});

final novelReaderControllerProvider = FutureProvider.autoDispose
    .family<NovelReaderController, String>((ref, mediaItemId) async {
      final controller = NovelReaderController(
        mediaItemId: mediaItemId,
        repository: await ref.watch(novelReaderRepositoryProvider.future),
      );
      ref.onDispose(controller.dispose);
      await controller.initialize();
      return controller;
    });
