import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/backup/data/backup_archive_validator.dart';
import 'package:mirascope/src/features/backup/data/dart_io_backup_exporter.dart';

void main() {
  test(
    'exports a self-validating archive and excludes transient data',
    () async {
      final root = await Directory.systemTemp.createTemp('backup-export-test-');
      addTearDown(() => root.delete(recursive: true));
      final support = Directory('${root.path}${Platform.pathSeparator}support');
      await _write(support, 'derived_txt/content/book.txt', [1, 2]);
      await _write(support, 'derived_txt/staging/book.tmp', [3]);
      await _write(support, 'derived_epub/content/epub/manifest.json', [4]);
      await _write(support, 'derived_manga/content/manga/manifest.json', [5]);
      await _write(support, 'derived_manga/cache/page.png', [6]);
      await _write(support, 'custom_covers/book/cover.png', [7]);
      await _write(support, 'unrelated/source.txt', [8]);
      final target = File('${root.path}${Platform.pathSeparator}library.zip');
      final exporter = DartIoBackupExporter(
        supportDirectory: support,
        databaseSchemaVersion: 6,
        clock: () => DateTime.utc(2026, 8, 22, 14),
        snapshotDatabase: (snapshot) => snapshot.writeAsBytes([9, 10]),
      );

      final result = await exporter.exportTo(target.path);

      expect(result.path, target.path);
      expect(result.fileCount, 5);
      final bytes = await target.readAsBytes();
      const BackupArchiveValidator().validate(bytes);
      final names = ZipDecoder()
          .decodeBytes(bytes)
          .files
          .where((file) => file.isFile)
          .map((file) => file.name)
          .toSet();
      expect(names, contains('data/mirascope.sqlite'));
      expect(names, contains('data/derived_txt/content/book.txt'));
      expect(names, contains('data/custom_covers/book/cover.png'));
      expect(names, isNot(contains('data/derived_txt/staging/book.tmp')));
      expect(names, isNot(contains('data/derived_manga/cache/page.png')));
      expect(names, isNot(contains('data/unrelated/source.txt')));
    },
  );

  test('refuses to overwrite an existing backup file', () async {
    final root = await Directory.systemTemp.createTemp('backup-export-test-');
    addTearDown(() => root.delete(recursive: true));
    final target = File('${root.path}${Platform.pathSeparator}existing.zip');
    await target.writeAsString('keep me');
    final exporter = DartIoBackupExporter(
      supportDirectory: Directory(
        '${root.path}${Platform.pathSeparator}support',
      ),
      databaseSchemaVersion: 6,
      clock: () => DateTime.utc(2026, 8, 22),
      snapshotDatabase: (snapshot) => snapshot.writeAsBytes([1]),
    );

    await expectLater(exporter.exportTo(target.path), throwsStateError);
    expect(await target.readAsString(), 'keep me');
  });
}

Future<void> _write(
  Directory support,
  String relativePath,
  List<int> bytes,
) async {
  final file = File(
    '${support.path}${Platform.pathSeparator}'
    '${relativePath.replaceAll('/', Platform.pathSeparator)}',
  );
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes);
}
