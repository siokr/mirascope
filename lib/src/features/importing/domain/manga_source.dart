import 'source_candidate.dart';

enum MangaSourceKind { directory, archive }

final class MangaSourceSelection {
  const MangaSourceSelection({required this.path, required this.kind});

  final String path;
  final MangaSourceKind kind;
}

final class MangaSourceCandidate implements SourceCandidate {
  const MangaSourceCandidate({
    required this.path,
    required this.kind,
    required this.fileSize,
    required this.modifiedAt,
    required this.fingerprint,
    required this.imageCount,
  });

  @override
  final String path;
  final MangaSourceKind kind;
  @override
  final int fileSize;
  @override
  final DateTime modifiedAt;
  @override
  final String fingerprint;
  final int imageCount;
}

abstract interface class MangaSourcePicker {
  Future<String?> pickArchive();

  Future<String?> pickDirectory();
}

abstract interface class MangaSourceInspector {
  Future<MangaSourceCandidate> inspect(MangaSourceSelection selection);
}
