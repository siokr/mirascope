import 'dart:convert';
import 'dart:io';

import '../application/apply_pending_restore.dart';

final class FilePendingRestoreStore implements PendingRestoreStore {
  const FilePendingRestoreStore(this.supportDirectory);

  final Directory supportDirectory;

  File get _marker => File(
    '${supportDirectory.path}${Platform.pathSeparator}'
    '.mirascope-pending-restore.json',
  );

  @override
  Future<String?> read() async {
    if (!await _marker.exists()) return null;
    final value = jsonDecode(await _marker.readAsString());
    if (value is! Map<String, Object?> || value['sourcePath'] is! String) {
      throw const FormatException('Invalid pending restore marker');
    }
    return value['sourcePath']! as String;
  }

  @override
  Future<void> schedule(String sourcePath) async {
    await supportDirectory.create(recursive: true);
    final temporary = File('${_marker.path}.tmp');
    await temporary.writeAsString(
      jsonEncode({'sourcePath': sourcePath}),
      flush: true,
    );
    if (await _marker.exists()) await _marker.delete();
    await temporary.rename(_marker.path);
  }

  @override
  Future<void> clear() async {
    if (await _marker.exists()) await _marker.delete();
  }
}
