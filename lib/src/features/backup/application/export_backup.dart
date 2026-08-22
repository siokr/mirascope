import '../domain/backup_destination_picker.dart';
import '../domain/backup_exporter.dart';

enum ExportBackupResult { succeeded, cancelled, failed }

typedef ExportBackupClock = DateTime Function();

final class ExportBackup {
  const ExportBackup({
    required this.destinationPicker,
    required this.exporter,
    required this.clock,
  });

  final BackupDestinationPicker destinationPicker;
  final BackupExporter exporter;
  final ExportBackupClock clock;

  Future<ExportBackupResult> call() async {
    try {
      final now = clock().toUtc();
      final date =
          '${now.year.toString().padLeft(4, '0')}'
          '${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}';
      final target = await destinationPicker.pickDestination(
        suggestedName: 'mirascope-backup-$date.zip',
      );
      if (target == null) return ExportBackupResult.cancelled;
      await exporter.exportTo(target);
      return ExportBackupResult.succeeded;
    } on Object {
      return ExportBackupResult.failed;
    }
  }
}
