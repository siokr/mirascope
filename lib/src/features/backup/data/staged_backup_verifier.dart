import 'dart:io';

import 'package:crypto/crypto.dart';

import '../domain/backup_validation.dart';

final class StagedBackupVerifier {
  const StagedBackupVerifier();

  Future<void> verify(Directory root, BackupManifest manifest) async {
    final declared = {for (final file in manifest.files) file.path: file};
    final found = <String, File>{};
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is Link) {
        throw const BackupValidationException(BackupValidationCode.unsafePath);
      }
      if (entity is! File) continue;
      final relative = entity.path
          .substring(root.path.length + 1)
          .replaceAll(Platform.pathSeparator, '/');
      if (!declared.containsKey(relative)) {
        throw const BackupValidationException(
          BackupValidationCode.unexpectedEntry,
        );
      }
      found[relative] = entity;
    }
    for (final entry in declared.entries) {
      final file = found[entry.key];
      if (file == null) {
        throw const BackupValidationException(
          BackupValidationCode.missingEntry,
        );
      }
      if (await file.length() != entry.value.size) {
        throw const BackupValidationException(
          BackupValidationCode.sizeMismatch,
        );
      }
      final digest = await sha256.bind(file.openRead()).first;
      if (digest.toString() != entry.value.sha256) {
        throw const BackupValidationException(
          BackupValidationCode.digestMismatch,
        );
      }
    }
  }
}
