final class BackupExportSummary {
  const BackupExportSummary({
    required this.path,
    required this.fileCount,
    required this.byteLength,
  });

  final String path;
  final int fileCount;
  final int byteLength;
}

abstract interface class BackupExporter {
  Future<BackupExportSummary> exportTo(String targetPath);
}
