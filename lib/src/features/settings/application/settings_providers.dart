import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/ids/id_generator.dart';
import 'reader_settings_controller.dart';

final globalReaderSettingsControllerProvider =
    FutureProvider.autoDispose<ReaderSettingsController>((ref) async {
      final controller = ReaderSettingsController(
        repository: ref.watch(readerPreferenceRepositoryProvider),
        idGenerator: const UuidIdGenerator(),
        clock: () => DateTime.now().toUtc(),
      );
      ref.onDispose(controller.dispose);
      await controller.initialize();
      return controller;
    });
