import 'effective_reader_preference.dart';
import 'reader_preference.dart';

abstract interface class ReaderPreferenceRepository {
  Future<ReaderPreference?> findGlobal();

  Future<ReaderPreference?> findForMedia(String mediaItemId);

  Future<EffectiveReaderPreference> resolveForMedia(String mediaItemId);

  Future<void> save(ReaderPreference preference);
}
