import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../data/dart_io_txt_source_inspector.dart';
import '../data/file_selector_txt_file_picker.dart';
import '../domain/txt_file_picker.dart';
import '../domain/txt_source_candidate.dart';
import 'prepare_txt_source.dart';

final txtFilePickerProvider = Provider<TxtFilePicker>((ref) {
  return const FileSelectorTxtFilePicker();
});

final txtSourceInspectorProvider = Provider<TxtSourceInspector>((ref) {
  return DartIoTxtSourceInspector();
});

final prepareTxtSourceProvider = Provider<PrepareTxtSource>((ref) {
  return PrepareTxtSource(
    filePicker: ref.watch(txtFilePickerProvider),
    sourceInspector: ref.watch(txtSourceInspectorProvider),
    importRepository: ref.watch(importRepositoryProvider),
  );
});
