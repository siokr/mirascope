import '../domain/backup_source_picker.dart';
import '../domain/backup_validation.dart';
import '../domain/backup_verifier.dart';

enum PreflightBackupFailure { invalidBackup, incompatibleVersion }

sealed class PreflightBackupResult {
  const PreflightBackupResult();
}

final class PreflightBackupCancelled extends PreflightBackupResult {
  const PreflightBackupCancelled();

  @override
  bool operator ==(Object other) => other is PreflightBackupCancelled;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class PreflightBackupRejected extends PreflightBackupResult {
  const PreflightBackupRejected(this.failure);

  final PreflightBackupFailure failure;

  @override
  bool operator ==(Object other) =>
      other is PreflightBackupRejected && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;
}

final class PreflightBackupReady extends PreflightBackupResult {
  const PreflightBackupReady({
    required this.sourcePath,
    required this.createdAt,
    required this.databaseSchemaVersion,
    required this.fileCount,
  });

  final String sourcePath;
  final DateTime createdAt;
  final int databaseSchemaVersion;
  final int fileCount;
}

final class PreflightBackup {
  const PreflightBackup({
    required this.sourcePicker,
    required this.verifier,
    required this.currentDatabaseSchemaVersion,
  });

  final BackupSourcePicker sourcePicker;
  final BackupVerifier verifier;
  final int currentDatabaseSchemaVersion;

  Future<PreflightBackupResult> call() async {
    try {
      final sourcePath = await sourcePicker.pickSource();
      if (sourcePath == null) return const PreflightBackupCancelled();
      final manifest = await verifier.verify(sourcePath);
      if (manifest.databaseSchemaVersion < 1 ||
          manifest.databaseSchemaVersion > currentDatabaseSchemaVersion) {
        return const PreflightBackupRejected(
          PreflightBackupFailure.incompatibleVersion,
        );
      }
      return PreflightBackupReady(
        sourcePath: sourcePath,
        createdAt: manifest.createdAt,
        databaseSchemaVersion: manifest.databaseSchemaVersion,
        fileCount: manifest.files.length,
      );
    } on BackupValidationException {
      return const PreflightBackupRejected(
        PreflightBackupFailure.invalidBackup,
      );
    } on Object {
      return const PreflightBackupRejected(
        PreflightBackupFailure.invalidBackup,
      );
    }
  }
}
