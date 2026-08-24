import '../domain/backup_committer.dart';
import '../domain/backup_stager.dart';

abstract interface class PendingRestoreStore {
  Future<String?> read();
  Future<void> schedule(String sourcePath);
  Future<void> clear();
}

final class ApplyPendingRestore {
  const ApplyPendingRestore({
    required this.pendingRestore,
    required this.stager,
    required this.committer,
  });

  final PendingRestoreStore pendingRestore;
  final BackupStager stager;
  final BackupCommitter committer;

  Future<void> call() async {
    final sourcePath = await pendingRestore.read();
    if (sourcePath == null) return;
    final stage = await stager.stage(sourcePath);
    await committer.commit(stage);
    await pendingRestore.clear();
  }
}
