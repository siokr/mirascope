import '../../importing/domain/import_record.dart';
import '../../library/domain/media_item.dart';
import '../../novel/domain/content_unit.dart';

final class MangaChapterDetails {
  const MangaChapterDetails({required this.unit, required this.pageCount});
  final ContentUnit unit;
  final int pageCount;
}

final class MangaDetails {
  MangaDetails({
    required this.mediaItem,
    required List<MangaChapterDetails> chapters,
    required this.sourceAvailable,
    required this.sourceKind,
  }) : chapters = List.unmodifiable(chapters);

  final MediaItem mediaItem;
  final List<MangaChapterDetails> chapters;
  final bool sourceAvailable;
  final ImportSourceKind? sourceKind;
  int get pageCount =>
      chapters.fold(0, (sum, chapter) => sum + chapter.pageCount);
}
