import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/backup/application/restore_backup.dart';
import 'package:mirascope/src/features/backup/domain/backup_committer.dart';
import 'package:mirascope/src/features/backup/domain/backup_stager.dart';
import 'package:mirascope/src/features/backup/domain/backup_validation.dart';

void main() {
  late Directory sandbox;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('mirascope_restore_test_');
  });

  tearDown(() async {
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  test('stages before closing the database and committing', () async {
    final events = <String>[];
    final phases = <RestoreBackupPhase>[];
    final stage = await _stage(sandbox);
    final useCase = RestoreBackup(
      stager: _Stager(stage, events),
      committer: _Committer(events),
      closeDatabase: () async => events.add('close'),
      currentDatabaseSchemaVersion: 6,
      reportPhase: phases.add,
    );

    expect(await useCase('D:/backup.zip'), const RestoreBackupSucceeded());
    expect(events, ['stage', 'close', 'commit']);
    expect(phases, [
      RestoreBackupPhase.staging,
      RestoreBackupPhase.closingDatabase,
      RestoreBackupPhase.committing,
    ]);
  });

  test('keeps the open database untouched when staging fails', () async {
    final events = <String>[];
    final useCase = RestoreBackup(
      stager: _Stager(
        await _stage(sandbox),
        events,
        error: const BackupValidationException(
          BackupValidationCode.digestMismatch,
        ),
      ),
      committer: _Committer(events),
      closeDatabase: () async => events.add('close'),
      currentDatabaseSchemaVersion: 6,
    );

    expect(await useCase('D:/broken.zip'), const RestoreBackupRejected());
    expect(events, ['stage']);
  });

  test(
    'requires restart when commit fails after the database closes',
    () async {
      final events = <String>[];
      final useCase = RestoreBackup(
        stager: _Stager(await _stage(sandbox), events),
        committer: _Committer(events, error: StateError('disk full')),
        closeDatabase: () async => events.add('close'),
        currentDatabaseSchemaVersion: 6,
      );

      expect(
        await useCase('D:/backup.zip'),
        const RestoreBackupRestartRequired(restored: false),
      );
      expect(events, ['stage', 'close', 'commit']);
    },
  );

  test('disposes staging and requires restart when closing fails', () async {
    final events = <String>[];
    final stage = await _stage(sandbox);
    final useCase = RestoreBackup(
      stager: _Stager(stage, events),
      committer: _Committer(events),
      closeDatabase: () async {
        events.add('close');
        throw StateError('close failed');
      },
      currentDatabaseSchemaVersion: 6,
    );

    expect(
      await useCase('D:/backup.zip'),
      const RestoreBackupRestartRequired(restored: false),
    );
    expect(events, ['stage', 'close']);
    expect(await stage.directory.exists(), isFalse);
  });

  test(
    'reports the preserved directory when automatic rollback fails',
    () async {
      final events = <String>[];
      final useCase = RestoreBackup(
        stager: _Stager(await _stage(sandbox), events),
        committer: _Committer(
          events,
          error: const BackupRollbackException(
            commitError: 'commit',
            rollbackError: 'rollback',
            recoveryDirectory: 'D:/recovery-copy',
          ),
        ),
        closeDatabase: () async => events.add('close'),
        currentDatabaseSchemaVersion: 6,
      );

      expect(
        await useCase('D:/backup.zip'),
        const RestoreBackupManualRecoveryRequired('D:/recovery-copy'),
      );
    },
  );

  test('rejects a swapped future-version backup before closing', () async {
    final events = <String>[];
    final stage = await _stage(sandbox, databaseSchemaVersion: 7);
    final useCase = RestoreBackup(
      stager: _Stager(stage, events),
      committer: _Committer(events),
      closeDatabase: () async => events.add('close'),
      currentDatabaseSchemaVersion: 6,
    );

    expect(await useCase('D:/future.zip'), const RestoreBackupRejected());
    expect(events, ['stage']);
    expect(await stage.directory.exists(), isFalse);
  });
}

Future<BackupStage> _stage(
  Directory sandbox, {
  int databaseSchemaVersion = 6,
}) async {
  final directory = await Directory('${sandbox.path}/stage').create();
  return BackupStage(
    directory: directory,
    manifest: BackupManifest(
      schemaVersion: 1,
      databaseSchemaVersion: databaseSchemaVersion,
      createdAt: DateTime.utc(2026, 8, 22),
      files: const [],
    ),
  );
}

final class _Stager implements BackupStager {
  _Stager(this.result, this.events, {this.error});
  final BackupStage result;
  final List<String> events;
  final Object? error;

  @override
  Future<BackupStage> stage(String sourcePath) async {
    events.add('stage');
    if (error case final value?) throw value;
    return result;
  }
}

final class _Committer implements BackupCommitter {
  _Committer(this.events, {this.error});
  final List<String> events;
  final Object? error;

  @override
  Future<void> commit(BackupStage stage) async {
    events.add('commit');
    if (error case final value?) throw value;
    await stage.dispose();
  }
}
