import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'restore_backup.dart';

enum RestoreStatusPhase {
  idle,
  preparing,
  staging,
  closingDatabase,
  committing,
  succeeded,
  rejected,
  restartRequired,
  manualRecovery,
}

final class RestoreStatus {
  const RestoreStatus(this.phase, {this.recoveryDirectory});

  final RestoreStatusPhase phase;
  final String? recoveryDirectory;
}

final restoreStatusProvider =
    NotifierProvider<RestoreStatusController, RestoreStatus>(
      RestoreStatusController.new,
    );

final class RestoreStatusController extends Notifier<RestoreStatus> {
  @override
  RestoreStatus build() => const RestoreStatus(RestoreStatusPhase.idle);

  void begin() {
    state = const RestoreStatus(RestoreStatusPhase.preparing);
  }

  void report(RestoreBackupPhase phase) {
    state = RestoreStatus(switch (phase) {
      RestoreBackupPhase.staging => RestoreStatusPhase.staging,
      RestoreBackupPhase.closingDatabase => RestoreStatusPhase.closingDatabase,
      RestoreBackupPhase.committing => RestoreStatusPhase.committing,
    });
  }

  void complete(RestoreBackupResult result) {
    state = switch (result) {
      RestoreBackupSucceeded() => const RestoreStatus(
        RestoreStatusPhase.succeeded,
      ),
      RestoreBackupRejected() => const RestoreStatus(
        RestoreStatusPhase.rejected,
      ),
      RestoreBackupRestartRequired() => const RestoreStatus(
        RestoreStatusPhase.restartRequired,
      ),
      RestoreBackupManualRecoveryRequired(:final recoveryDirectory) =>
        RestoreStatus(
          RestoreStatusPhase.manualRecovery,
          recoveryDirectory: recoveryDirectory,
        ),
    };
  }

  void reset() {
    state = const RestoreStatus(RestoreStatusPhase.idle);
  }
}
