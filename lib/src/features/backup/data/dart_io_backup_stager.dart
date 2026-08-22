import 'dart:io';

import 'package:archive/archive.dart';

import '../domain/backup_stager.dart';
import 'backup_archive_validator.dart';
import 'staged_backup_verifier.dart';

final class DartIoBackupStager implements BackupStager {
  const DartIoBackupStager({
    required this.stagingRoot,
    this.archiveValidator = const BackupArchiveValidator(),
    this.stagedVerifier = const StagedBackupVerifier(),
  });

  final Directory stagingRoot;
  final BackupArchiveValidator archiveValidator;
  final StagedBackupVerifier stagedVerifier;

  @override
  Future<BackupStage> stage(String sourcePath) async {
    final bytes = await File(sourcePath).readAsBytes();
    final manifest = archiveValidator.validate(bytes);
    await stagingRoot.create(recursive: true);
    final directory = await stagingRoot.createTemp('restore-');
    try {
      final archive = ZipDecoder().decodeBytes(bytes, verify: true);
      final files = {
        for (final file in archive.files)
          if (file.isFile) file.name: file,
      };
      for (final declared in manifest.files) {
        final content = files[declared.path]!.readBytes()!;
        final target = File(
          '${directory.path}${Platform.pathSeparator}'
          '${declared.path.replaceAll('/', Platform.pathSeparator)}',
        );
        await target.parent.create(recursive: true);
        await target.writeAsBytes(content, flush: true);
      }
      await stagedVerifier.verify(directory, manifest);
      return BackupStage(directory: directory, manifest: manifest);
    } on Object {
      if (await directory.exists()) await directory.delete(recursive: true);
      rethrow;
    }
  }
}
