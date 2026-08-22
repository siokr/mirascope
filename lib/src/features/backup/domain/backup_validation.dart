enum BackupValidationCode {
  invalidArchive,
  invalidManifest,
  unsupportedSchema,
  unsafePath,
  duplicateEntry,
  missingEntry,
  unexpectedEntry,
  sizeMismatch,
  digestMismatch,
}

final class BackupValidationException implements Exception {
  const BackupValidationException(this.code);

  final BackupValidationCode code;

  @override
  String toString() => 'BackupValidationException(${code.name})';
}

final class BackupFileManifest {
  const BackupFileManifest({
    required this.path,
    required this.size,
    required this.sha256,
  });

  final String path;
  final int size;
  final String sha256;
}

final class BackupManifest {
  BackupManifest({
    required this.schemaVersion,
    required this.databaseSchemaVersion,
    required this.createdAt,
    required List<BackupFileManifest> files,
  }) : files = List.unmodifiable(files);

  final int schemaVersion;
  final int databaseSchemaVersion;
  final DateTime createdAt;
  final List<BackupFileManifest> files;
}
