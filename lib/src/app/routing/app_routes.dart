abstract final class AppRoutes {
  static const library = '/library';
  static const libraryArchive = '/library/archive';
  static const settings = '/settings';

  static String novelDetails(String mediaItemId) =>
      '/novel/${Uri.encodeComponent(mediaItemId)}';

  static String novelReader(String mediaItemId) =>
      '/novel/${Uri.encodeComponent(mediaItemId)}/read';
}
