import 'source_candidate.dart';

final class EpubSourceCandidate implements SourceCandidate {
  const EpubSourceCandidate({
    required this.path,
    required this.fileSize,
    required this.modifiedAt,
    required this.fingerprint,
  });

  @override
  final String path;
  @override
  final int fileSize;
  @override
  final DateTime modifiedAt;
  @override
  final String fingerprint;
}

abstract interface class EpubSourceInspector {
  Future<EpubSourceCandidate> inspect(String path);
}
