import 'package:file_selector/file_selector.dart';

import '../domain/txt_file_picker.dart';

final class FileSelectorTxtFilePicker implements TxtFilePicker {
  const FileSelectorTxtFilePicker();

  static const _txtTypeGroup = XTypeGroup(
    label: 'TXT 文本文档',
    extensions: <String>['txt'],
  );

  @override
  Future<String?> pickTxtFile() async {
    final file = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[_txtTypeGroup],
      confirmButtonText: '选择',
    );
    return file?.path;
  }
}
