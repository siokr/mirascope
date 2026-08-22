import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import '../domain/backup_validation.dart';

final class BackupArchiveValidator {
  const BackupArchiveValidator();

  BackupManifest validate(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes, verify: true);
      final files = <String, ArchiveFile>{};
      for (final file in archive.files) {
        final path = file.name;
        _validatePath(path);
        if (files.containsKey(path)) {
          throw const BackupValidationException(
            BackupValidationCode.duplicateEntry,
          );
        }
        if (file.isSymbolicLink) {
          throw const BackupValidationException(
            BackupValidationCode.unsafePath,
          );
        }
        if (file.isFile) files[path] = file;
      }

      final manifestFile = files.remove('manifest.json');
      if (manifestFile == null) {
        throw const BackupValidationException(
          BackupValidationCode.invalidManifest,
        );
      }
      final manifestBytes = manifestFile.readBytes();
      if (manifestBytes == null) {
        throw const BackupValidationException(
          BackupValidationCode.invalidManifest,
        );
      }
      final manifest = _parseManifest(manifestBytes);
      final declared = {for (final file in manifest.files) file.path: file};
      if (declared.length != manifest.files.length) {
        throw const BackupValidationException(
          BackupValidationCode.duplicateEntry,
        );
      }
      if (!declared.containsKey('data/mirascope.sqlite')) {
        throw const BackupValidationException(
          BackupValidationCode.missingEntry,
        );
      }
      for (final entry in declared.entries) {
        _validatePath(entry.key);
        final archiveFile = files.remove(entry.key);
        if (archiveFile == null) {
          throw const BackupValidationException(
            BackupValidationCode.missingEntry,
          );
        }
        final content = archiveFile.readBytes();
        if (content == null) {
          throw const BackupValidationException(
            BackupValidationCode.invalidArchive,
          );
        }
        if (content.length != entry.value.size) {
          throw const BackupValidationException(
            BackupValidationCode.sizeMismatch,
          );
        }
        if (sha256.convert(content).toString() != entry.value.sha256) {
          throw const BackupValidationException(
            BackupValidationCode.digestMismatch,
          );
        }
      }
      if (files.isNotEmpty) {
        throw const BackupValidationException(
          BackupValidationCode.unexpectedEntry,
        );
      }
      return manifest;
    } on BackupValidationException {
      rethrow;
    } on Object {
      throw const BackupValidationException(
        BackupValidationCode.invalidArchive,
      );
    }
  }

  BackupManifest _parseManifest(Uint8List bytes) {
    try {
      final value = jsonDecode(utf8.decode(bytes));
      if (value is! Map<String, Object?> ||
          value['format'] != 'mirascope-backup') {
        throw const BackupValidationException(
          BackupValidationCode.invalidManifest,
        );
      }
      final schemaVersion = value['schemaVersion'];
      if (schemaVersion != 1) {
        throw const BackupValidationException(
          BackupValidationCode.unsupportedSchema,
        );
      }
      final databaseSchemaVersion = value['databaseSchemaVersion'];
      final createdAtValue = value['createdAt'];
      final fileValues = value['files'];
      if (databaseSchemaVersion is! int ||
          createdAtValue is! String ||
          fileValues is! List<Object?>) {
        throw const BackupValidationException(
          BackupValidationCode.invalidManifest,
        );
      }
      final createdAt = DateTime.tryParse(createdAtValue);
      if (createdAt == null || !createdAt.isUtc) {
        throw const BackupValidationException(
          BackupValidationCode.invalidManifest,
        );
      }
      final files = <BackupFileManifest>[];
      for (final fileValue in fileValues) {
        if (fileValue is! Map<String, Object?> ||
            fileValue['path'] is! String ||
            fileValue['size'] is! int ||
            fileValue['sha256'] is! String) {
          throw const BackupValidationException(
            BackupValidationCode.invalidManifest,
          );
        }
        final digest = fileValue['sha256']! as String;
        final size = fileValue['size']! as int;
        if (size < 0 || !RegExp(r'^[a-f0-9]{64}$').hasMatch(digest)) {
          throw const BackupValidationException(
            BackupValidationCode.invalidManifest,
          );
        }
        files.add(
          BackupFileManifest(
            path: fileValue['path']! as String,
            size: size,
            sha256: digest,
          ),
        );
      }
      files.sort((left, right) => left.path.compareTo(right.path));
      return BackupManifest(
        schemaVersion: 1,
        databaseSchemaVersion: databaseSchemaVersion,
        createdAt: createdAt,
        files: files,
      );
    } on BackupValidationException {
      rethrow;
    } on Object {
      throw const BackupValidationException(
        BackupValidationCode.invalidManifest,
      );
    }
  }

  void _validatePath(String path) {
    if (path.isEmpty ||
        path.startsWith('/') ||
        path.contains('\\') ||
        path.contains(':') ||
        path
            .split('/')
            .any((part) => part.isEmpty || part == '.' || part == '..')) {
      throw const BackupValidationException(BackupValidationCode.unsafePath);
    }
  }
}
