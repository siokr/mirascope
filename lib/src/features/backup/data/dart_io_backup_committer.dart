import 'dart:io';

import '../domain/backup_committer.dart';
import '../domain/backup_stager.dart';

abstract interface class BackupFileOperations {
  Future<bool> exists(String path);
  Future<void> createDirectory(String path);
  Future<void> move(String sourcePath, String targetPath);
  Future<void> delete(String path);
}

final class DartIoBackupFileOperations implements BackupFileOperations {
  const DartIoBackupFileOperations();

  @override
  Future<bool> exists(String path) async {
    return await FileSystemEntity.type(path, followLinks: false) !=
        FileSystemEntityType.notFound;
  }

  @override
  Future<void> createDirectory(String path) async {
    await Directory(path).create(recursive: true);
  }

  @override
  Future<void> move(String sourcePath, String targetPath) async {
    final type = await FileSystemEntity.type(sourcePath, followLinks: false);
    switch (type) {
      case FileSystemEntityType.file:
        await File(sourcePath).rename(targetPath);
      case FileSystemEntityType.directory:
        await Directory(sourcePath).rename(targetPath);
      case FileSystemEntityType.link:
        await Link(sourcePath).rename(targetPath);
      case FileSystemEntityType.notFound:
        throw FileSystemException('Source does not exist', sourcePath);
      case FileSystemEntityType.pipe:
      case FileSystemEntityType.unixDomainSock:
        throw FileSystemException('Unsupported entity type', sourcePath);
    }
  }

  @override
  Future<void> delete(String path) async {
    final type = await FileSystemEntity.type(path, followLinks: false);
    switch (type) {
      case FileSystemEntityType.file:
        await File(path).delete();
      case FileSystemEntityType.directory:
        await Directory(path).delete(recursive: true);
      case FileSystemEntityType.link:
        await Link(path).delete();
      case FileSystemEntityType.notFound:
        return;
      case FileSystemEntityType.pipe:
      case FileSystemEntityType.unixDomainSock:
        throw FileSystemException('Unsupported entity type', path);
    }
  }
}

final class DartIoBackupCommitter implements BackupCommitter {
  const DartIoBackupCommitter({
    required this.supportDirectory,
    this.operations = const DartIoBackupFileOperations(),
  });

  final Directory supportDirectory;
  final BackupFileOperations operations;

  @override
  Future<void> commit(BackupStage stage) async {
    await supportDirectory.create(recursive: true);
    final rollback = await supportDirectory.createTemp('.mirascope-rollback-');
    final movedOld = <_ManagedPath>[];
    final installed = <_ManagedPath>[];
    try {
      for (final path in _managedPaths) {
        final target = _targetPath(path);
        if (!await operations.exists(target)) continue;
        final recovery = _recoveryPath(rollback, path);
        await operations.createDirectory(File(recovery).parent.path);
        await operations.move(target, recovery);
        movedOld.add(path);
      }
      for (final path in _managedPaths) {
        if (path.stageRelative == null) continue;
        final source = _stagePath(stage, path);
        if (!await operations.exists(source)) continue;
        final target = _targetPath(path);
        await operations.createDirectory(File(target).parent.path);
        await operations.move(source, target);
        installed.add(path);
      }
    } on Object catch (commitError, commitStack) {
      Object? rollbackError;
      try {
        for (final path in installed.reversed) {
          await operations.delete(_targetPath(path));
        }
        for (final path in movedOld.reversed) {
          final recovery = _recoveryPath(rollback, path);
          final target = _targetPath(path);
          await operations.createDirectory(File(target).parent.path);
          await operations.move(recovery, target);
        }
      } on Object catch (error) {
        rollbackError = error;
      } finally {
        await _ignoreFailure(stage.dispose);
      }
      if (rollbackError != null) {
        throw BackupRollbackException(
          commitError: commitError,
          rollbackError: rollbackError,
          recoveryDirectory: rollback.path,
        );
      }
      await _ignoreFailure(() => operations.delete(rollback.path));
      Error.throwWithStackTrace(commitError, commitStack);
    }
    await _ignoreFailure(stage.dispose);
    await _ignoreFailure(() => operations.delete(rollback.path));
  }

  Future<void> _ignoreFailure(Future<void> Function() operation) async {
    try {
      await operation();
    } on Object {
      // The data transaction has already committed or rolled back. Temporary
      // cleanup must never reverse that outcome or hide the primary failure.
    }
  }

  String _targetPath(_ManagedPath path) =>
      '${supportDirectory.path}${Platform.pathSeparator}'
      '${path.targetRelative.replaceAll('/', Platform.pathSeparator)}';

  String _recoveryPath(Directory rollback, _ManagedPath path) =>
      '${rollback.path}${Platform.pathSeparator}'
      '${path.targetRelative.replaceAll('/', Platform.pathSeparator)}';

  String _stagePath(BackupStage stage, _ManagedPath path) =>
      '${stage.directory.path}${Platform.pathSeparator}'
      '${path.stageRelative!.replaceAll('/', Platform.pathSeparator)}';
}

final class _ManagedPath {
  const _ManagedPath({required this.targetRelative, this.stageRelative});

  final String targetRelative;
  final String? stageRelative;
}

const _managedPaths = [
  _ManagedPath(
    targetRelative: 'mirascope.sqlite',
    stageRelative: 'data/mirascope.sqlite',
  ),
  _ManagedPath(targetRelative: 'mirascope.sqlite-wal'),
  _ManagedPath(targetRelative: 'mirascope.sqlite-shm'),
  _ManagedPath(targetRelative: 'mirascope.sqlite-journal'),
  _ManagedPath(
    targetRelative: 'derived_txt/content',
    stageRelative: 'data/derived_txt/content',
  ),
  _ManagedPath(
    targetRelative: 'derived_epub/content',
    stageRelative: 'data/derived_epub/content',
  ),
  _ManagedPath(
    targetRelative: 'derived_manga/content',
    stageRelative: 'data/derived_manga/content',
  ),
  _ManagedPath(
    targetRelative: 'custom_covers',
    stageRelative: 'data/custom_covers',
  ),
  _ManagedPath(targetRelative: 'derived_manga/cache'),
];
