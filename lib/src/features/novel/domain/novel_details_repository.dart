import 'novel_details.dart';

abstract interface class NovelDetailsRepository {
  Future<NovelDetails?> findDetails(String mediaItemId);
}
