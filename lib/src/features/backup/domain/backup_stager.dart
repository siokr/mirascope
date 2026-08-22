import 'dart:io';

import 'backup_validation.dart';

abstract interface class BackupStager {
  Future<BackupStage> stage(String sourcePath);
}

final class BackupStage {
  BackupStage({required this.directory, required this.manifest});

  final Directory directory;
  final BackupManifest manifest;

  Future<void> dispose() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}
