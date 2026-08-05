import 'package:file_selector/file_selector.dart';

import '../domain/epub_file_picker.dart';

final class FileSelectorEpubFilePicker implements EpubFilePicker {
  const FileSelectorEpubFilePicker();

  static const _epubTypeGroup = XTypeGroup(
    label: 'EPUB 电子书',
    extensions: <String>['epub'],
  );

  @override
  Future<String?> pickEpubFile() async {
    final file = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[_epubTypeGroup],
      confirmButtonText: '选择',
    );
    return file?.path;
  }
}
