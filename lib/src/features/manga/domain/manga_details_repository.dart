import 'manga_details.dart';

abstract interface class MangaDetailsRepository {
  Future<MangaDetails?> findDetails(String mediaItemId);
}
