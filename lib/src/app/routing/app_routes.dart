abstract final class AppRoutes {
  static const library = '/library';
  static const settings = '/settings';

  static String novelDetails(String mediaItemId) => '/novel/$mediaItemId';

  static String novelReader(String mediaItemId) => '/novel/$mediaItemId/read';
}
