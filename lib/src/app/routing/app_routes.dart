abstract final class AppRoutes {
  static const library = '/library';
  static const libraryArchive = '/library/archive';
  static const settings = '/settings';

  static String novelDetails(String mediaItemId) =>
      '/novel/${Uri.encodeComponent(mediaItemId)}';

  static String novelReader(String mediaItemId, {String? contentUnitId}) {
    final path = '/novel/${Uri.encodeComponent(mediaItemId)}/read';
    return contentUnitId == null
        ? path
        : '$path?chapter=${Uri.encodeQueryComponent(contentUnitId)}';
  }
}
