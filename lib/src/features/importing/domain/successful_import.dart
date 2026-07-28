import '../../library/domain/library_entry.dart';
import '../../library/domain/media_item.dart';
import '../../novel/domain/content_unit.dart';
import 'import_record.dart';

final class SuccessfulImport {
  const SuccessfulImport({
    required this.mediaItem,
    required this.libraryEntry,
    required this.contentUnits,
    required this.importRecord,
  });

  final MediaItem mediaItem;
  final LibraryEntry libraryEntry;
  final List<ContentUnit> contentUnits;
  final ImportRecord importRecord;
}
