import '../../library/domain/media_item.dart';
import 'content_unit.dart';

final class ReaderBook {
  ReaderBook({required this.mediaItem, required List<ContentUnit> chapters})
    : chapters = List<ContentUnit>.unmodifiable(chapters);

  final MediaItem mediaItem;
  final List<ContentUnit> chapters;
}

final class ReaderChapter {
  const ReaderChapter({required this.unit, required this.text});

  final ContentUnit unit;
  final String text;
}
