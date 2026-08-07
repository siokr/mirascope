import '../../library/domain/media_item.dart';
import '../../importing/domain/import_record.dart';
import 'content_unit.dart';

final class NovelDetails {
  NovelDetails({
    required this.mediaItem,
    required List<ContentUnit> chapters,
    required this.sourceAvailable,
    required this.sourceKind,
  }) : chapters = List<ContentUnit>.unmodifiable(chapters);

  final MediaItem mediaItem;
  final List<ContentUnit> chapters;
  final bool sourceAvailable;
  final ImportSourceKind? sourceKind;
}
