import '../../library/domain/library_entry.dart';
import '../../library/domain/media_item.dart';
import '../../novel/domain/content_unit.dart';
import 'import_record.dart';

final class SuccessfulImport {
  SuccessfulImport({
    required this.mediaItem,
    required this.libraryEntry,
    required List<ContentUnit> contentUnits,
    required this.importRecord,
  }) : contentUnits = List<ContentUnit>.unmodifiable(contentUnits);

  final MediaItem mediaItem;
  final LibraryEntry libraryEntry;
  final List<ContentUnit> contentUnits;
  final ImportRecord importRecord;
}
