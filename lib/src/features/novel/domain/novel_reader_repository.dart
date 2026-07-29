import 'content_unit.dart';
import 'reader_book.dart';

abstract interface class NovelReaderRepository {
  Future<ReaderBook?> loadBook(String mediaItemId);
  Future<ReaderChapter> readChapter(ContentUnit unit);
}
