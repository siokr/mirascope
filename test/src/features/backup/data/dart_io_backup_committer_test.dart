import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/backup/data/dart_io_backup_committer.dart';
import 'package:mirascope/src/features/backup/domain/backup_committer.dart';
import 'package:mirascope/src/features/backup/domain/backup_stager.dart';
import 'package:mirascope/src/features/backup/domain/backup_validation.dart';

void main() {
  late Directory sandbox;
  late Directory support;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('mirascope_commit_test_');
    support = await Directory('${sandbox.path}/support').create();
  });

  tearDown(() async {
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  test('replaces only managed data and clears the manga cache', () async {
    await _write(support, 'mirascope.sqlite', 'old-db');
    await _write(support, 'derived_txt/content/old.txt', 'old-text');
    await _write(support, 'derived_manga/cache/page.png', 'old-cache');
    await _write(support, 'unrelated/settings.keep', 'keep-me');
    final stage = await _stage(sandbox, {
      'data/mirascope.sqlite': 'new-db',
      'data/derived_txt/content/new.txt': 'new-text',
    });

    await DartIoBackupCommitter(supportDirectory: support).commit(stage);

    expect(await _read(support, 'mirascope.sqlite'), 'new-db');
    expect(await _read(support, 'derived_txt/content/new.txt'), 'new-text');
    expect(
      await File('${support.path}/derived_txt/content/old.txt').exists(),
      isFalse,
    );
    expect(
      await Directory('${support.path}/derived_manga/cache').exists(),
      isFalse,
    );
    expect(await _read(support, 'unrelated/settings.keep'), 'keep-me');
    expect(await stage.directory.exists(), isFalse);
    expect(
      await support
          .list()
          .where(
            (entry) => entry.uri.pathSegments.any(
              (part) => part.startsWith('.mirascope-rollback-'),
            ),
          )
          .toList(),
      isEmpty,
    );
  });

  test('restores all old data when installing staged content fails', () async {
    await _write(support, 'mirascope.sqlite', 'old-db');
    await _write(support, 'custom_covers/old.png', 'old-cover');
    final stage = await _stage(sandbox, {
      'data/mirascope.sqlite': 'new-db',
      'data/custom_covers/new.png': 'new-cover',
    });
    final operations = _FailingOperations(
      failWhenSourceContains: 'data${Platform.pathSeparator}custom_covers',
    );

    await expectLater(
      DartIoBackupCommitter(
        supportDirectory: support,
        operations: operations,
      ).commit(stage),
      throwsA(isA<FileSystemException>()),
    );

    expect(await _read(support, 'mirascope.sqlite'), 'old-db');
    expect(await _read(support, 'custom_covers/old.png'), 'old-cover');
    expect(
      await File('${support.path}/custom_covers/new.png').exists(),
      isFalse,
    );
    expect(await stage.directory.exists(), isFalse);
    expect(
      await support
          .list()
          .where((entry) => entry.path.contains('.mirascope-rollback-'))
          .toList(),
      isEmpty,
    );
  });

  test(
    'preserves the rollback copy when automatic rollback also fails',
    () async {
      await _write(support, 'mirascope.sqlite', 'old-db');
      final stage = await _stage(sandbox, {
        'data/mirascope.sqlite': 'new-db',
        'data/custom_covers/new.png': 'new-cover',
      });
      final operations = _RollbackFailingOperations();

      late BackupRollbackException failure;
      try {
        await DartIoBackupCommitter(
          supportDirectory: support,
          operations: operations,
        ).commit(stage);
        fail('commit should fail');
      } on BackupRollbackException catch (error) {
        failure = error;
      }

      expect(await Directory(failure.recoveryDirectory).exists(), isTrue);
      expect(
        await File(
          '${failure.recoveryDirectory}${Platform.pathSeparator}mirascope.sqlite',
        ).readAsString(),
        'old-db',
      );
      expect(await stage.directory.exists(), isFalse);
    },
  );

  test(
    'does not undo a committed restore when rollback cleanup fails',
    () async {
      await _write(support, 'mirascope.sqlite', 'old-db');
      final stage = await _stage(sandbox, {'data/mirascope.sqlite': 'new-db'});

      await DartIoBackupCommitter(
        supportDirectory: support,
        operations: _CleanupFailingOperations(),
      ).commit(stage);

      expect(await _read(support, 'mirascope.sqlite'), 'new-db');
      expect(await stage.directory.exists(), isFalse);
      expect(
        await support
            .list()
            .where((entry) => entry.path.contains('.mirascope-rollback-'))
            .toList(),
        hasLength(1),
      );
    },
  );
}

Future<BackupStage> _stage(Directory sandbox, Map<String, String> files) async {
  final directory = await Directory('${sandbox.path}/stage').create();
  for (final entry in files.entries) {
    await _write(directory, entry.key, entry.value);
  }
  return BackupStage(
    directory: directory,
    manifest: BackupManifest(
      schemaVersion: 1,
      databaseSchemaVersion: 6,
      createdAt: DateTime.utc(2026, 8, 22),
      files: const [],
    ),
  );
}

Future<void> _write(Directory root, String relative, String value) async {
  final file = File(
    '${root.path}${Platform.pathSeparator}'
    '${relative.replaceAll('/', Platform.pathSeparator)}',
  );
  await file.parent.create(recursive: true);
  await file.writeAsString(value);
}

Future<String> _read(Directory root, String relative) {
  return File(
    '${root.path}${Platform.pathSeparator}'
    '${relative.replaceAll('/', Platform.pathSeparator)}',
  ).readAsString();
}

final class _FailingOperations implements BackupFileOperations {
  _FailingOperations({required this.failWhenSourceContains});

  final String failWhenSourceContains;
  final delegate = const DartIoBackupFileOperations();
  var failed = false;

  @override
  Future<void> createDirectory(String path) => delegate.createDirectory(path);

  @override
  Future<void> delete(String path) => delegate.delete(path);

  @override
  Future<bool> exists(String path) => delegate.exists(path);

  @override
  Future<void> move(String sourcePath, String targetPath) async {
    if (!failed && sourcePath.contains(failWhenSourceContains)) {
      failed = true;
      throw FileSystemException('injected install failure', sourcePath);
    }
    await delegate.move(sourcePath, targetPath);
  }
}

final class _RollbackFailingOperations implements BackupFileOperations {
  final delegate = const DartIoBackupFileOperations();
  var installFailed = false;

  @override
  Future<void> createDirectory(String path) => delegate.createDirectory(path);

  @override
  Future<void> delete(String path) => delegate.delete(path);

  @override
  Future<bool> exists(String path) => delegate.exists(path);

  @override
  Future<void> move(String sourcePath, String targetPath) async {
    if (!installFailed && sourcePath.contains('custom_covers')) {
      installFailed = true;
      throw FileSystemException('injected install failure', sourcePath);
    }
    if (installFailed && sourcePath.contains('.mirascope-rollback-')) {
      throw FileSystemException('injected rollback failure', sourcePath);
    }
    await delegate.move(sourcePath, targetPath);
  }
}

final class _CleanupFailingOperations implements BackupFileOperations {
  final delegate = const DartIoBackupFileOperations();

  @override
  Future<void> createDirectory(String path) => delegate.createDirectory(path);

  @override
  Future<void> delete(String path) {
    if (path.contains('.mirascope-rollback-')) {
      throw FileSystemException('injected cleanup failure', path);
    }
    return delegate.delete(path);
  }

  @override
  Future<bool> exists(String path) => delegate.exists(path);

  @override
  Future<void> move(String sourcePath, String targetPath) =>
      delegate.move(sourcePath, targetPath);
}
