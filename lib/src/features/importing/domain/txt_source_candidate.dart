import 'source_candidate.dart';

final class TxtSourceCandidate implements SourceCandidate {
  const TxtSourceCandidate({
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

abstract interface class TxtSourceInspector {
  Future<TxtSourceCandidate> inspect(String path);
}
