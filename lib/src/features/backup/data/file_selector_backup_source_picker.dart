import 'package:file_selector/file_selector.dart';

import '../domain/backup_source_picker.dart';

final class FileSelectorBackupSourcePicker implements BackupSourcePicker {
  const FileSelectorBackupSourcePicker();

  @override
  Future<String?> pickSource() async {
    const group = XTypeGroup(label: 'Mirascope 备份', extensions: ['zip']);
    final file = await openFile(
      acceptedTypeGroups: const [group],
      confirmButtonText: '检查',
    );
    return file?.path;
  }
}
