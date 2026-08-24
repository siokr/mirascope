import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/backup/application/apply_pending_restore.dart';
import 'package:mirascope/src/features/backup/domain/backup_committer.dart';
import 'package:mirascope/src/features/backup/domain/backup_stager.dart';
import 'package:mirascope/src/features/backup/domain/backup_validation.dart';

void main() {
  test('startup commits a pending backup before clearing its marker', () async {
    final events = <String>[];
    final pending = _Pending(events, 'D:/backup.zip');
    final useCase = ApplyPendingRestore(
      pendingRestore: pending,
      stager: _Stager(events),
      committer: _Committer(events),
    );

    await useCase();

    expect(events, ['read', 'stage', 'commit', 'clear']);
  });
}

final class _Pending implements PendingRestoreStore {
  _Pending(this.events, this.path);
  final List<String> events;
  final String? path;

  @override
  Future<String?> read() async {
    events.add('read');
    return path;
  }

  @override
  Future<void> schedule(String sourcePath) async {}

  @override
  Future<void> clear() async => events.add('clear');
}

final class _Stager implements BackupStager {
  _Stager(this.events);
  final List<String> events;

  @override
  Future<BackupStage> stage(String sourcePath) async {
    events.add('stage');
    return BackupStage(
      directory: await Directory.systemTemp.createTemp('pending_restore_'),
      manifest: BackupManifest(
        schemaVersion: 1,
        databaseSchemaVersion: 6,
        createdAt: DateTime.utc(2026, 8, 24),
        files: const [],
      ),
    );
  }
}

final class _Committer implements BackupCommitter {
  _Committer(this.events);
  final List<String> events;

  @override
  Future<void> commit(BackupStage stage) async {
    events.add('commit');
    await stage.dispose();
  }
}
