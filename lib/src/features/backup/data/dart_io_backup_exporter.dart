import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';

import 'backup_archive_validator.dart';
import '../domain/backup_exporter.dart';

typedef BackupClock = DateTime Function();
typedef DatabaseSnapshotter = Future<void> Function(File target);

final class DartIoBackupExporter implements BackupExporter {
  const DartIoBackupExporter({
    required this.supportDirectory,
    required this.databaseSchemaVersion,
    required this.clock,
    required this.snapshotDatabase,
    this.validator = const BackupArchiveValidator(),
  });

  final Directory supportDirectory;
  final int databaseSchemaVersion;
  final BackupClock clock;
  final DatabaseSnapshotter snapshotDatabase;
  final BackupArchiveValidator validator;

  @override
  Future<BackupExportSummary> exportTo(String targetPath) async {
    final target = File(targetPath);
    if (await target.exists()) {
      throw StateError('backup_target_already_exists');
    }
    if (!await target.parent.exists()) {
      throw StateError('backup_target_directory_missing');
    }
    final staging = await target.parent.createTemp('.mirascope-export-');
    try {
      final databaseSnapshot = File(
        '${staging.path}${Platform.pathSeparator}mirascope.sqlite',
      );
      await snapshotDatabase(databaseSnapshot);
      if (!await databaseSnapshot.exists()) {
        throw StateError('database_snapshot_missing');
      }

      final files = <_BackupSource>[
        _BackupSource(databaseSnapshot, 'data/mirascope.sqlite'),
      ];
      await _collectDirectory(
        files,
        Directory(
          '${supportDirectory.path}${Platform.pathSeparator}derived_txt'
          '${Platform.pathSeparator}content',
        ),
        'data/derived_txt/content',
      );
      await _collectDirectory(
        files,
        Directory(
          '${supportDirectory.path}${Platform.pathSeparator}derived_epub'
          '${Platform.pathSeparator}content',
        ),
        'data/derived_epub/content',
      );
      await _collectDirectory(
        files,
        Directory(
          '${supportDirectory.path}${Platform.pathSeparator}derived_manga'
          '${Platform.pathSeparator}content',
        ),
        'data/derived_manga/content',
      );
      await _collectDirectory(
        files,
        Directory(
          '${supportDirectory.path}${Platform.pathSeparator}custom_covers',
        ),
        'data/custom_covers',
      );
      files.sort(
        (left, right) => left.archivePath.compareTo(right.archivePath),
      );

      final entries = <Map<String, Object?>>[];
      for (final source in files) {
        final digest = await sha256.bind(source.file.openRead()).first;
        entries.add({
          'path': source.archivePath,
          'size': await source.file.length(),
          'sha256': digest.toString(),
        });
      }
      final createdAt = clock().toUtc();
      final manifest = jsonEncode({
        'format': 'mirascope-backup',
        'schemaVersion': 1,
        'databaseSchemaVersion': databaseSchemaVersion,
        'createdAt': createdAt.toIso8601String(),
        'files': entries,
      });

      final stagedArchive = File(
        '${staging.path}${Platform.pathSeparator}backup.zip',
      );
      final encoder = ZipFileEncoder();
      encoder.create(stagedArchive.path, modified: createdAt);
      try {
        encoder.addArchiveFile(ArchiveFile.string('manifest.json', manifest));
        for (final source in files) {
          await encoder.addFile(source.file, source.archivePath);
        }
      } finally {
        await encoder.close();
      }

      validator.validate(await stagedArchive.readAsBytes());
      final byteLength = await stagedArchive.length();
      await stagedArchive.rename(target.path);
      return BackupExportSummary(
        path: target.path,
        fileCount: files.length,
        byteLength: byteLength,
      );
    } finally {
      if (await staging.exists()) await staging.delete(recursive: true);
    }
  }

  Future<void> _collectDirectory(
    List<_BackupSource> output,
    Directory root,
    String archiveRoot,
  ) async {
    if (!await root.exists()) return;
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is Link) throw StateError('backup_source_contains_link');
      if (entity is! File) continue;
      final relative = entity.path
          .substring(root.path.length + 1)
          .replaceAll(Platform.pathSeparator, '/');
      output.add(_BackupSource(entity, '$archiveRoot/$relative'));
    }
  }
}

final class _BackupSource {
  const _BackupSource(this.file, this.archivePath);

  final File file;
  final String archivePath;
}
