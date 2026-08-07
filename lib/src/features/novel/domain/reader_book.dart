import '../../library/domain/media_item.dart';
import 'content_unit.dart';

final class ReaderBook {
  ReaderBook({required this.mediaItem, required List<ContentUnit> chapters})
    : chapters = List<ContentUnit>.unmodifiable(chapters);

  final MediaItem mediaItem;
  final List<ContentUnit> chapters;
}

final class ReaderChapter {
  const ReaderChapter({
    required this.unit,
    required this.text,
    this.blocks = const <ReaderBlock>[],
  });

  final ContentUnit unit;
  final String text;
  final List<ReaderBlock> blocks;

  bool get isSemantic => blocks.isNotEmpty;

  String progressLocator({
    required int characterOffset,
    required double fraction,
  }) {
    if (!isSemantic) return 'char-v1:$characterOffset';
    final safeFraction = fraction.clamp(0.0, 1.0);
    final position = safeFraction * blocks.length;
    final blockIndex = position.floor().clamp(0, blocks.length - 1);
    final withinBlockFraction = safeFraction == 1 ? 1.0 : position - blockIndex;
    final block = blocks[blockIndex];
    final offset = block.text == null
        ? 0
        : (block.text!.length * withinBlockFraction).round();
    return 'epub-block-v1:$blockIndex:$offset';
  }
}

enum ReaderBlockKind { paragraph, heading, listItem, quote, divider, image }

final class ReaderTextStyleSpan {
  const ReaderTextStyleSpan({
    required this.start,
    required this.end,
    required this.bold,
    required this.italic,
  });

  final int start;
  final int end;
  final bool bold;
  final bool italic;
}

final class ReaderBlock {
  const ReaderBlock({
    required this.kind,
    this.text,
    this.headingLevel,
    this.listDepth,
    this.ordered,
    this.imagePath,
    this.altText,
    this.styleSpans = const <ReaderTextStyleSpan>[],
  });

  final ReaderBlockKind kind;
  final String? text;
  final int? headingLevel;
  final int? listDepth;
  final bool? ordered;
  final String? imagePath;
  final String? altText;
  final List<ReaderTextStyleSpan> styleSpans;
}
