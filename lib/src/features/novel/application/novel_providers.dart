import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/ids/id_generator.dart';
import '../data/dart_io_novel_reader_repository.dart';
import '../domain/novel_details.dart';
import '../domain/novel_reader_repository.dart';
import '../../settings/application/reader_settings_controller.dart';
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

typedef NovelReaderRequest = ({
  String mediaItemId,
  String? initialContentUnitId,
});

final novelReaderControllerProvider = FutureProvider.autoDispose
    .family<NovelReaderController, NovelReaderRequest>((ref, request) async {
      final controller = NovelReaderController(
        mediaItemId: request.mediaItemId,
        initialContentUnitId: request.initialContentUnitId,
        repository: await ref.watch(novelReaderRepositoryProvider.future),
        progressRepository: ref.watch(readingProgressRepositoryProvider),
        idGenerator: const UuidIdGenerator(),
        clock: () => DateTime.now().toUtc(),
      );
      ref.onDispose(() {
        unawaited(controller.close());
        controller.dispose();
      });
      await controller.initialize();
      return controller;
    });

final readerSettingsControllerProvider = FutureProvider.autoDispose
    .family<ReaderSettingsController, String>((ref, mediaItemId) async {
      final controller = ReaderSettingsController(
        mediaItemId: mediaItemId,
        repository: ref.watch(readerPreferenceRepositoryProvider),
        idGenerator: const UuidIdGenerator(),
        clock: () => DateTime.now().toUtc(),
      );
      ref.onDispose(controller.dispose);
      await controller.initialize();
      return controller;
    });
