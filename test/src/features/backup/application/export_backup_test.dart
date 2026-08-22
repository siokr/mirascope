import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/backup/application/export_backup.dart';
import 'package:mirascope/src/features/backup/domain/backup_destination_picker.dart';
import 'package:mirascope/src/features/backup/domain/backup_exporter.dart';

void main() {
  test('cancelling the save dialog does not start an export', () async {
    final exporter = _Exporter();
    final useCase = ExportBackup(
      destinationPicker: _Picker(null),
      exporter: exporter,
      clock: () => DateTime.utc(2026, 8, 22),
    );

    expect(await useCase(), ExportBackupResult.cancelled);
    expect(exporter.paths, isEmpty);
  });

  test('exports to the selected path with a dated suggested name', () async {
    final exporter = _Exporter();
    final picker = _Picker('D:/Backups/library.zip');
    final useCase = ExportBackup(
      destinationPicker: picker,
      exporter: exporter,
      clock: () => DateTime.utc(2026, 8, 22),
    );

    expect(await useCase(), ExportBackupResult.succeeded);
    expect(picker.suggestedNames, ['mirascope-backup-20260822.zip']);
    expect(exporter.paths, ['D:/Backups/library.zip']);
  });

  test('returns a stable failure when exporting throws', () async {
    final useCase = ExportBackup(
      destinationPicker: _Picker('D:/backup.zip'),
      exporter: _Exporter()..error = StateError('private path'),
      clock: () => DateTime.utc(2026, 8, 22),
    );

    expect(await useCase(), ExportBackupResult.failed);
  });
}

final class _Picker implements BackupDestinationPicker {
  _Picker(this.path);
  final String? path;
  final suggestedNames = <String>[];

  @override
  Future<String?> pickDestination({required String suggestedName}) async {
    suggestedNames.add(suggestedName);
    return path;
  }
}

final class _Exporter implements BackupExporter {
  final paths = <String>[];
  Object? error;

  @override
  Future<BackupExportSummary> exportTo(String targetPath) async {
    if (error case final value?) throw value;
    paths.add(targetPath);
    return BackupExportSummary(path: targetPath, fileCount: 1, byteLength: 1);
  }
}
