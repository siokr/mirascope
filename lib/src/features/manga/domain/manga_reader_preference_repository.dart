import 'manga_reader_preference.dart';

abstract interface class MangaReaderPreferenceRepository {
  Future<MangaReaderPreference?> findForMedia(String mediaItemId);
  Future<void> save(MangaReaderPreference preference);
}
