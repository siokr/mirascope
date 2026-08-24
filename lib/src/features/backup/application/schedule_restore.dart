import '../domain/backup_stager.dart';
import 'apply_pending_restore.dart';
import 'restore_backup.dart';

final class ScheduleRestore {
  const ScheduleRestore({required this.stager, required this.pendingRestore});

  final BackupStager stager;
  final PendingRestoreStore pendingRestore;

  Future<RestoreBackupResult> call(String sourcePath) async {
    BackupStage? stage;
    try {
      stage = await stager.stage(sourcePath);
      await pendingRestore.schedule(sourcePath);
    } on Object {
      return const RestoreBackupRejected();
    } finally {
      try {
        await stage?.dispose();
      } on Object {
        // A validated temporary copy is disposable after scheduling.
      }
    }
    return const RestoreBackupRestartRequired(restored: false);
  }
}
