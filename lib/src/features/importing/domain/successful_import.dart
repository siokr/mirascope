import '../../library/domain/library_entry.dart';
import '../../library/domain/media_item.dart';
import '../../manga/domain/manga_page.dart';
import '../../novel/domain/content_unit.dart';
import 'import_record.dart';

final class SuccessfulImport {
  SuccessfulImport({
    required this.mediaItem,
    required this.libraryEntry,
    required List<ContentUnit> contentUnits,
    List<MangaPage> mangaPages = const [],
    required this.importRecord,
  }) : contentUnits = List<ContentUnit>.unmodifiable(contentUnits),
       mangaPages = List<MangaPage>.unmodifiable(mangaPages);

  final MediaItem mediaItem;
  final LibraryEntry libraryEntry;
  final List<ContentUnit> contentUnits;
  final List<MangaPage> mangaPages;
  final ImportRecord importRecord;
}
