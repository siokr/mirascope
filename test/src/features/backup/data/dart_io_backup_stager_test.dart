import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/backup/data/dart_io_backup_stager.dart';
import 'package:mirascope/src/features/backup/data/staged_backup_verifier.dart';
import 'package:mirascope/src/features/backup/domain/backup_validation.dart';

void main() {
  late Directory sandbox;
  late Directory stagingRoot;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('mirascope_stage_test_');
    stagingRoot = await Directory('${sandbox.path}/staging').create();
  });

  tearDown(() async {
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  test('extracts a valid backup into an isolated staging directory', () async {
    final source = await _writeBackup(
      sandbox,
      files: {
        'data/mirascope.sqlite': Uint8List.fromList([1, 2, 3, 4]),
        'data/custom_covers/cover.png': Uint8List.fromList([5, 6]),
      },
    );
    final stager = DartIoBackupStager(stagingRoot: stagingRoot);

    final stage = await stager.stage(source.path);
    addTearDown(stage.dispose);

    expect(stage.directory.parent.path, stagingRoot.path);
    expect(
      await File('${stage.directory.path}/data/mirascope.sqlite').readAsBytes(),
      [1, 2, 3, 4],
    );
    expect(stage.manifest.files, hasLength(2));
    await stage.dispose();
    expect(await stage.directory.exists(), isFalse);
  });

  test('post-extraction verification detects a tampered staged file', () async {
    final source = await _writeBackup(
      sandbox,
      files: {
        'data/mirascope.sqlite': Uint8List.fromList([1, 2, 3, 4]),
      },
    );
    final stage = await DartIoBackupStager(
      stagingRoot: stagingRoot,
    ).stage(source.path);
    addTearDown(stage.dispose);
    await File(
      '${stage.directory.path}/data/mirascope.sqlite',
    ).writeAsBytes([9, 9]);

    await expectLater(
      const StagedBackupVerifier().verify(stage.directory, stage.manifest),
      throwsA(
        isA<BackupValidationException>().having(
          (error) => error.code,
          'code',
          BackupValidationCode.sizeMismatch,
        ),
      ),
    );
  });

  test(
    'removes its temporary directory when archive validation fails',
    () async {
      final source = File('${sandbox.path}/broken.zip');
      await source.writeAsBytes([1, 2, 3]);

      await expectLater(
        DartIoBackupStager(stagingRoot: stagingRoot).stage(source.path),
        throwsA(isA<BackupValidationException>()),
      );
      expect(await stagingRoot.list().toList(), isEmpty);
    },
  );
}

Future<File> _writeBackup(
  Directory directory, {
  required Map<String, Uint8List> files,
}) async {
  final manifest = jsonEncode({
    'format': 'mirascope-backup',
    'schemaVersion': 1,
    'databaseSchemaVersion': 6,
    'createdAt': '2026-08-22T12:00:00.000Z',
    'files': [
      for (final entry in files.entries)
        {
          'path': entry.key,
          'size': entry.value.length,
          'sha256': sha256.convert(entry.value).toString(),
        },
    ],
  });
  final archive = Archive()..add(ArchiveFile.string('manifest.json', manifest));
  for (final entry in files.entries) {
    archive.add(ArchiveFile.bytes(entry.key, entry.value));
  }
  final source = File('${directory.path}/backup.zip');
  await source.writeAsBytes(ZipEncoder().encodeBytes(archive));
  return source;
}
