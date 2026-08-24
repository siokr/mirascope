import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/backup/application/apply_pending_restore.dart';
import 'package:mirascope/src/features/backup/application/restore_backup.dart';
import 'package:mirascope/src/features/backup/application/schedule_restore.dart';
import 'package:mirascope/src/features/backup/domain/backup_stager.dart';
import 'package:mirascope/src/features/backup/domain/backup_validation.dart';

void main() {
  test(
    'running app validates then schedules without closing database',
    () async {
      final events = <String>[];
      final stager = _Stager(events);
      final useCase = ScheduleRestore(
        stager: stager,
        pendingRestore: _Pending(events),
      );

      expect(
        await useCase('D:/backup.zip'),
        const RestoreBackupRestartRequired(restored: false),
      );
      expect(events, ['stage', 'schedule']);
      expect(await stager.directory!.exists(), isFalse);
    },
  );
}

final class _Pending implements PendingRestoreStore {
  _Pending(this.events);
  final List<String> events;
  @override
  Future<void> schedule(String sourcePath) async => events.add('schedule');
  @override
  Future<String?> read() async => null;
  @override
  Future<void> clear() async {}
}

final class _Stager implements BackupStager {
  _Stager(this.events);
  final List<String> events;
  Directory? directory;
  @override
  Future<BackupStage> stage(String sourcePath) async {
    events.add('stage');
    directory = await Directory.systemTemp.createTemp('schedule_');
    return BackupStage(
      directory: directory!,
      manifest: BackupManifest(
        schemaVersion: 1,
        databaseSchemaVersion: 6,
        createdAt: DateTime.utc(2026, 8, 24),
        files: const [],
      ),
    );
  }
}
