import 'backup_stager.dart';

abstract interface class BackupCommitter {
  Future<void> commit(BackupStage stage);
}

final class BackupRollbackException implements Exception {
  const BackupRollbackException({
    required this.commitError,
    required this.rollbackError,
    required this.recoveryDirectory,
  });

  final Object commitError;
  final Object rollbackError;
  final String recoveryDirectory;

  @override
  String toString() => 'BackupRollbackException($recoveryDirectory)';
}
