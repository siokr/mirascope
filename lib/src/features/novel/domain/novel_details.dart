import '../../library/domain/media_item.dart';
import 'content_unit.dart';

final class NovelDetails {
  NovelDetails({
    required this.mediaItem,
    required List<ContentUnit> chapters,
    required this.sourceAvailable,
  }) : chapters = List<ContentUnit>.unmodifiable(chapters);

  final MediaItem mediaItem;
  final List<ContentUnit> chapters;
  final bool sourceAvailable;
}
