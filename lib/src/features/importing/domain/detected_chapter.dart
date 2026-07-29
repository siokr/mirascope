enum ChapterHeadingKind {
  chineseOrdinal,
  chineseVolume,
  englishChapter,
  fallback,
}

final class DetectedChapter {
  const DetectedChapter({
    required this.title,
    required this.headingKind,
    required this.startOffset,
    required this.bodyStartOffset,
    required this.endOffset,
    this.headingStartOffset,
  });

  final String title;
  final ChapterHeadingKind headingKind;
  final int startOffset;
  final int? headingStartOffset;
  final int bodyStartOffset;
  final int endOffset;
}
