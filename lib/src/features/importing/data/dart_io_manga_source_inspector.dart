import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/manga_source.dart';
import 'dart_io_txt_source_inspector.dart' show mapFileSystemFailure;

final class DartIoMangaSourceInspector implements MangaSourceInspector {
  const DartIoMangaSourceInspector();

  static const supportedImageExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  @override
  Future<MangaSourceCandidate> inspect(MangaSourceSelection selection) {
    return switch (selection.kind) {
      MangaSourceKind.archive => _inspectArchive(selection.path),
      MangaSourceKind.directory => _inspectDirectory(selection.path),
    };
  }

  Future<MangaSourceCandidate> _inspectArchive(String path) async {
    try {
      if (!_hasArchiveExtension(path)) {
        throw AppFailure.fromCode(AppErrorCode.mangaInvalidSource);
      }
      final before = await FileStat.stat(path);
      if (before.type != FileSystemEntityType.file) {
        throw AppFailure.fromCode(AppErrorCode.fileNotFound);
      }
      if (before.size == 0) {
        throw AppFailure.fromCode(AppErrorCode.emptyFile);
      }
      final header = await File(
        path,
      ).openRead(0, 4).expand((part) => part).toList();
      if (!_hasZipSignature(header)) {
        throw AppFailure.fromCode(AppErrorCode.mangaInvalidSource);
      }
      final digest = await sha256.bind(File(path).openRead()).single;
      final after = await FileStat.stat(path);
      if (!_sameFileStat(before, after)) {
        throw AppFailure.fromCode(AppErrorCode.sourceChanged);
      }
      return MangaSourceCandidate(
        path: path,
        kind: MangaSourceKind.archive,
        fileSize: after.size,
        modifiedAt: after.modified.toUtc(),
        fingerprint: 'sha256:$digest:${after.size}',
        imageCount: 0,
      );
    } on AppFailure {
      rethrow;
    } on FileSystemException catch (error) {
      throw mapFileSystemFailure(error);
    } on Object {
      throw AppFailure.fromCode(AppErrorCode.storageFailed);
    }
  }

  Future<MangaSourceCandidate> _inspectDirectory(String path) async {
    try {
      final root = Directory(path);
      final rootStat = await root.stat();
      if (rootStat.type != FileSystemEntityType.directory) {
        throw AppFailure.fromCode(AppErrorCode.fileNotFound);
      }
      final before = await _directoryEntries(root);
      if (before.isEmpty) {
        throw AppFailure.fromCode(AppErrorCode.mangaNoImages);
      }

      final manifest = StringBuffer();
      var totalSize = 0;
      var latestModified = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      for (final entry in before) {
        final digest = await sha256.bind(File(entry.path).openRead()).single;
        manifest
          ..write(entry.relativePath)
          ..write('\u0000')
          ..write(entry.size)
          ..write('\u0000')
          ..write(digest)
          ..write('\n');
        totalSize += entry.size;
        if (entry.modifiedAt.isAfter(latestModified)) {
          latestModified = entry.modifiedAt;
        }
      }

      final after = await _directoryEntries(root);
      if (!_sameDirectoryEntries(before, after)) {
        throw AppFailure.fromCode(AppErrorCode.sourceChanged);
      }
      final digest = sha256.convert(utf8.encode(manifest.toString()));
      return MangaSourceCandidate(
        path: path,
        kind: MangaSourceKind.directory,
        fileSize: totalSize,
        modifiedAt: latestModified,
        fingerprint: 'sha256:$digest:$totalSize:${before.length}',
        imageCount: before.length,
      );
    } on AppFailure {
      rethrow;
    } on FileSystemException catch (error) {
      throw mapFileSystemFailure(error);
    } on Object {
      throw AppFailure.fromCode(AppErrorCode.storageFailed);
    }
  }

  Future<List<_DirectoryImageEntry>> _directoryEntries(Directory root) async {
    final entries = <_DirectoryImageEntry>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) {
        continue;
      }
      final relativePath = _relativePath(root.path, entity.path);
      if (_isHidden(relativePath) || !_isSupportedImage(relativePath)) {
        continue;
      }
      final stat = await entity.stat();
      entries.add(
        _DirectoryImageEntry(
          path: entity.path,
          relativePath: relativePath,
          size: stat.size,
          modifiedAt: stat.modified.toUtc(),
        ),
      );
    }
    entries.sort((left, right) {
      final folded = left.relativePath.toLowerCase().compareTo(
        right.relativePath.toLowerCase(),
      );
      return folded != 0
          ? folded
          : left.relativePath.compareTo(right.relativePath);
    });
    return entries;
  }

  static String _relativePath(String root, String path) {
    final rootWithSeparator = root.endsWith(Platform.pathSeparator)
        ? root
        : '$root${Platform.pathSeparator}';
    if (!path.startsWith(rootWithSeparator)) {
      throw AppFailure.fromCode(AppErrorCode.mangaInvalidSource);
    }
    return path
        .substring(rootWithSeparator.length)
        .replaceAll(Platform.pathSeparator, '/');
  }

  static bool _isHidden(String relativePath) => relativePath
      .split('/')
      .any((segment) => segment.startsWith('.') && segment.length > 1);

  static bool _isSupportedImage(String path) {
    final separator = path.lastIndexOf('.');
    return separator >= 0 &&
        supportedImageExtensions.contains(
          path.substring(separator + 1).toLowerCase(),
        );
  }

  static bool _hasArchiveExtension(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.zip') || lower.endsWith('.cbz');
  }

  static bool _hasZipSignature(List<int> bytes) =>
      bytes.length >= 4 &&
      bytes[0] == 0x50 &&
      bytes[1] == 0x4b &&
      ((bytes[2] == 0x03 && bytes[3] == 0x04) ||
          (bytes[2] == 0x05 && bytes[3] == 0x06) ||
          (bytes[2] == 0x07 && bytes[3] == 0x08));

  static bool _sameFileStat(FileStat before, FileStat after) =>
      after.type == FileSystemEntityType.file &&
      before.size == after.size &&
      before.modified.toUtc() == after.modified.toUtc();

  static bool _sameDirectoryEntries(
    List<_DirectoryImageEntry> before,
    List<_DirectoryImageEntry> after,
  ) {
    if (before.length != after.length) {
      return false;
    }
    for (var index = 0; index < before.length; index++) {
      if (before[index] != after[index]) {
        return false;
      }
    }
    return true;
  }
}

final class _DirectoryImageEntry {
  const _DirectoryImageEntry({
    required this.path,
    required this.relativePath,
    required this.size,
    required this.modifiedAt,
  });

  final String path;
  final String relativePath;
  final int size;
  final DateTime modifiedAt;

  @override
  bool operator ==(Object other) =>
      other is _DirectoryImageEntry &&
      path == other.path &&
      relativePath == other.relativePath &&
      size == other.size &&
      modifiedAt == other.modifiedAt;

  @override
  int get hashCode => Object.hash(path, relativePath, size, modifiedAt);
}
