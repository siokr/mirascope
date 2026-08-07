abstract interface class SourceCandidate {
  String get path;
  int get fileSize;
  DateTime get modifiedAt;
  String get fingerprint;
}
