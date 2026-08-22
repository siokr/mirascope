import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/backup/data/dart_io_backup_verifier.dart';

void main() {
  test('reads and validates the selected backup file', () async {
    final directory = await Directory.systemTemp.createTemp(
      'mirascope_backup_verify_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final database = Uint8List.fromList([1, 2, 3, 4]);
    final manifest = jsonEncode({
      'format': 'mirascope-backup',
      'schemaVersion': 1,
      'databaseSchemaVersion': 6,
      'createdAt': '2026-08-22T12:00:00.000Z',
      'files': [
        {
          'path': 'data/mirascope.sqlite',
          'size': database.length,
          'sha256': sha256.convert(database).toString(),
        },
      ],
    });
    final archive = Archive()
      ..add(ArchiveFile.string('manifest.json', manifest))
      ..add(ArchiveFile.bytes('data/mirascope.sqlite', database));
    final source = File('${directory.path}/backup.zip');
    await source.writeAsBytes(ZipEncoder().encodeBytes(archive));

    final result = await const DartIoBackupVerifier().verify(source.path);

    expect(result.databaseSchemaVersion, 6);
    expect(result.files.single.path, 'data/mirascope.sqlite');
  });
}
