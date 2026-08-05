final class EpubSourceCandidate {
  const EpubSourceCandidate({
    required this.path,
    required this.fileSize,
    required this.modifiedAt,
    required this.fingerprint,
  });

  final String path;
  final int fileSize;
  final DateTime modifiedAt;
  final String fingerprint;
}

abstract interface class EpubSourceInspector {
  Future<EpubSourceCandidate> inspect(String path);
}
