import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/database_providers.dart';
import '../data/dart_io_backup_exporter.dart';
import '../data/drift_database_snapshotter.dart';
import '../data/file_selector_backup_destination_picker.dart';
import '../domain/backup_destination_picker.dart';
import '../domain/backup_exporter.dart';
import 'export_backup.dart';

final backupClockProvider = Provider<ExportBackupClock>((ref) {
  return () => DateTime.now().toUtc();
});

final backupDestinationPickerProvider = Provider<BackupDestinationPicker>((
  ref,
) {
  return const FileSelectorBackupDestinationPicker();
});

final backupExporterProvider = FutureProvider<BackupExporter>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  return DartIoBackupExporter(
    supportDirectory: await getApplicationSupportDirectory(),
    databaseSchemaVersion: database.schemaVersion,
    clock: ref.watch(backupClockProvider),
    snapshotDatabase: DriftDatabaseSnapshotter(database).call,
  );
});

final exportBackupProvider = FutureProvider<ExportBackup>((ref) async {
  return ExportBackup(
    destinationPicker: ref.watch(backupDestinationPickerProvider),
    exporter: await ref.watch(backupExporterProvider.future),
    clock: ref.watch(backupClockProvider),
  );
});
