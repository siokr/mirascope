import '../domain/backup_committer.dart';
import '../domain/backup_stager.dart';

typedef CloseDatabase = Future<void> Function();
typedef ReportRestorePhase = void Function(RestoreBackupPhase phase);

enum RestoreBackupPhase { staging, closingDatabase, committing }

sealed class RestoreBackupResult {
  const RestoreBackupResult();
}

final class RestoreBackupSucceeded extends RestoreBackupResult {
  const RestoreBackupSucceeded();

  @override
  bool operator ==(Object other) => other is RestoreBackupSucceeded;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class RestoreBackupRejected extends RestoreBackupResult {
  const RestoreBackupRejected();

  @override
  bool operator ==(Object other) => other is RestoreBackupRejected;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class RestoreBackupRestartRequired extends RestoreBackupResult {
  const RestoreBackupRestartRequired({required this.restored});

  final bool restored;

  @override
  bool operator ==(Object other) =>
      other is RestoreBackupRestartRequired && other.restored == restored;

  @override
  int get hashCode => restored.hashCode;
}

final class RestoreBackupManualRecoveryRequired extends RestoreBackupResult {
  const RestoreBackupManualRecoveryRequired(this.recoveryDirectory);

  final String recoveryDirectory;

  @override
  bool operator ==(Object other) =>
      other is RestoreBackupManualRecoveryRequired &&
      other.recoveryDirectory == recoveryDirectory;

  @override
  int get hashCode => recoveryDirectory.hashCode;
}

final class RestoreBackup {
  const RestoreBackup({
    required this.stager,
    required this.committer,
    required this.closeDatabase,
    required this.currentDatabaseSchemaVersion,
    this.reportPhase,
  });

  final BackupStager stager;
  final BackupCommitter committer;
  final CloseDatabase closeDatabase;
  final int currentDatabaseSchemaVersion;
  final ReportRestorePhase? reportPhase;

  Future<RestoreBackupResult> call(String sourcePath) async {
    late final BackupStage stage;
    reportPhase?.call(RestoreBackupPhase.staging);
    try {
      stage = await stager.stage(sourcePath);
    } on Object {
      return const RestoreBackupRejected();
    }
    if (stage.manifest.databaseSchemaVersion < 1 ||
        stage.manifest.databaseSchemaVersion > currentDatabaseSchemaVersion) {
      await stage.dispose();
      return const RestoreBackupRejected();
    }
    reportPhase?.call(RestoreBackupPhase.closingDatabase);
    try {
      await closeDatabase();
    } on Object {
      await stage.dispose();
      return const RestoreBackupRestartRequired(restored: false);
    }
    reportPhase?.call(RestoreBackupPhase.committing);
    try {
      await committer.commit(stage);
      return const RestoreBackupSucceeded();
    } on BackupRollbackException catch (error) {
      return RestoreBackupManualRecoveryRequired(error.recoveryDirectory);
    } on Object {
      return const RestoreBackupRestartRequired(restored: false);
    }
  }
}
