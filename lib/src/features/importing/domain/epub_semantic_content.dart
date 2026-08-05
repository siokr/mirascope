enum EpubBlockKind { paragraph, heading, listItem, quote, divider, image }

final class EpubTextStyleSpan {
  const EpubTextStyleSpan({
    required this.start,
    required this.end,
    this.bold = false,
    this.italic = false,
  });

  final int start;
  final int end;
  final bool bold;
  final bool italic;
}

final class EpubSemanticBlock {
  const EpubSemanticBlock._({
    required this.kind,
    this.text,
    this.sourceId,
    this.headingLevel,
    this.listDepth,
    this.ordered,
    this.imagePath,
    this.imageMediaType,
    this.altText,
    this.styleSpans = const <EpubTextStyleSpan>[],
  });

  factory EpubSemanticBlock.text({
    required EpubBlockKind kind,
    required String text,
    String? sourceId,
    int? headingLevel,
    int? listDepth,
    bool? ordered,
    List<EpubTextStyleSpan> styleSpans = const <EpubTextStyleSpan>[],
  }) => EpubSemanticBlock._(
    kind: kind,
    text: text,
    sourceId: sourceId,
    headingLevel: headingLevel,
    listDepth: listDepth,
    ordered: ordered,
    styleSpans: List.unmodifiable(styleSpans),
  );

  factory EpubSemanticBlock.divider({String? sourceId}) =>
      EpubSemanticBlock._(kind: EpubBlockKind.divider, sourceId: sourceId);

  factory EpubSemanticBlock.image({
    required String imagePath,
    required String imageMediaType,
    String? altText,
    String? sourceId,
  }) => EpubSemanticBlock._(
    kind: EpubBlockKind.image,
    imagePath: imagePath,
    imageMediaType: imageMediaType,
    altText: altText,
    sourceId: sourceId,
  );

  final EpubBlockKind kind;
  final String? text;
  final String? sourceId;
  final int? headingLevel;
  final int? listDepth;
  final bool? ordered;
  final String? imagePath;
  final String? imageMediaType;
  final String? altText;
  final List<EpubTextStyleSpan> styleSpans;
}

final class EpubSemanticChapter {
  const EpubSemanticChapter({
    required this.manifestId,
    required this.sourcePath,
    required this.title,
    required this.linear,
    required this.blocks,
  });

  final String manifestId;
  final String sourcePath;
  final String title;
  final bool linear;
  final List<EpubSemanticBlock> blocks;
}
