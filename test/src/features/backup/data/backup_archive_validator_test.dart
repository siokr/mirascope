import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/backup/data/backup_archive_validator.dart';
import 'package:mirascope/src/features/backup/domain/backup_validation.dart';

void main() {
  test('accepts a v1 archive whose declared files match size and digest', () {
    final database = Uint8List.fromList([1, 2, 3, 4]);
    final archive = _backupArchive({
      'data/mirascope.sqlite': database,
      'data/derived_txt/content/book.txt': Uint8List.fromList([5, 6]),
    });

    final manifest = const BackupArchiveValidator().validate(archive);

    expect(manifest.schemaVersion, 1);
    expect(manifest.files.map((file) => file.path), [
      'data/derived_txt/content/book.txt',
      'data/mirascope.sqlite',
    ]);
  });

  test('rejects content whose digest differs from the manifest', () {
    final archive = _backupArchive(
      {
        'data/mirascope.sqlite': Uint8List.fromList([9, 9]),
      },
      manifestBytes: {
        'data/mirascope.sqlite': Uint8List.fromList([1, 2]),
      },
    );

    expect(
      () => const BackupArchiveValidator().validate(archive),
      throwsA(
        isA<BackupValidationException>().having(
          (error) => error.code,
          'code',
          BackupValidationCode.digestMismatch,
        ),
      ),
    );
  });

  test('rejects traversal paths before any extraction', () {
    final archive = _backupArchive({
      '../outside.sqlite': Uint8List.fromList([1]),
    });

    expect(
      () => const BackupArchiveValidator().validate(archive),
      throwsA(
        isA<BackupValidationException>().having(
          (error) => error.code,
          'code',
          BackupValidationCode.unsafePath,
        ),
      ),
    );
  });
}

Uint8List _backupArchive(
  Map<String, Uint8List> files, {
  Map<String, Uint8List>? manifestBytes,
}) {
  final declared = manifestBytes ?? files;
  final manifest = jsonEncode({
    'format': 'mirascope-backup',
    'schemaVersion': 1,
    'databaseSchemaVersion': 6,
    'createdAt': '2026-08-22T12:00:00.000Z',
    'files': [
      for (final entry in declared.entries)
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
  return ZipEncoder().encodeBytes(archive);
}
