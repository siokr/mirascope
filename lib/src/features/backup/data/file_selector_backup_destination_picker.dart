import 'package:file_selector/file_selector.dart';

import '../domain/backup_destination_picker.dart';

final class FileSelectorBackupDestinationPicker
    implements BackupDestinationPicker {
  const FileSelectorBackupDestinationPicker();

  static const _backupType = XTypeGroup(
    label: 'Mirascope 备份',
    extensions: ['zip'],
  );

  @override
  Future<String?> pickDestination({required String suggestedName}) async {
    final location = await getSaveLocation(
      acceptedTypeGroups: const [_backupType],
      suggestedName: suggestedName,
      confirmButtonText: '导出',
    );
    return location?.path;
  }
}
