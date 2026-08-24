import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/database_providers.dart';
import '../data/dart_io_backup_exporter.dart';
import '../data/dart_io_backup_committer.dart';
import '../data/dart_io_backup_stager.dart';
import '../data/drift_database_snapshotter.dart';
import '../data/dart_io_backup_verifier.dart';
import '../data/file_selector_backup_destination_picker.dart';
import '../data/file_selector_backup_source_picker.dart';
import '../data/file_pending_restore_store.dart';
import '../domain/backup_destination_picker.dart';
import '../domain/backup_committer.dart';
import '../domain/backup_exporter.dart';
import '../domain/backup_source_picker.dart';
import '../domain/backup_verifier.dart';
import '../domain/backup_stager.dart';
import 'export_backup.dart';
import 'preflight_backup.dart';
import 'restore_backup.dart';
import 'restore_status.dart';
import 'schedule_restore.dart';
import 'apply_pending_restore.dart';

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

final backupSourcePickerProvider = Provider<BackupSourcePicker>((ref) {
  return const FileSelectorBackupSourcePicker();
});

final backupVerifierProvider = Provider<BackupVerifier>((ref) {
  return const DartIoBackupVerifier();
});

final preflightBackupProvider = Provider<PreflightBackup>((ref) {
  return PreflightBackup(
    sourcePicker: ref.watch(backupSourcePickerProvider),
    verifier: ref.watch(backupVerifierProvider),
    currentDatabaseSchemaVersion: ref.watch(appDatabaseProvider).schemaVersion,
  );
});

final backupStagerProvider = FutureProvider<BackupStager>((ref) async {
  final support = await getApplicationSupportDirectory();
  return DartIoBackupStager(
    stagingRoot: Directory(
      '${support.path}${Platform.pathSeparator}.mirascope-restore-staging',
    ),
  );
});

final backupCommitterProvider = FutureProvider<BackupCommitter>((ref) async {
  return DartIoBackupCommitter(
    supportDirectory: await getApplicationSupportDirectory(),
  );
});

final pendingRestoreStoreProvider = FutureProvider<PendingRestoreStore>((
  ref,
) async {
  return FilePendingRestoreStore(await getApplicationSupportDirectory());
});

typedef RestoreBackupCommand =
    Future<RestoreBackupResult> Function(String sourcePath);

final restoreBackupCommandProvider = FutureProvider<RestoreBackupCommand>((
  ref,
) async {
  final restore = ScheduleRestore(
    stager: await ref.watch(backupStagerProvider.future),
    pendingRestore: await ref.watch(pendingRestoreStoreProvider.future),
  );
  return (sourcePath) {
    ref.read(restoreStatusProvider.notifier).report(RestoreBackupPhase.staging);
    return restore(sourcePath);
  };
});
