final class MangaProgressLocator {
  const MangaProgressLocator({
    required this.pageIndex,
    required this.intraPageFraction,
  });

  final int pageIndex;
  final double intraPageFraction;

  String encode() {
    if (pageIndex < 0) {
      throw ArgumentError.value(pageIndex, 'pageIndex', 'must be non-negative');
    }
    if (!intraPageFraction.isFinite ||
        intraPageFraction < 0 ||
        intraPageFraction > 1) {
      throw ArgumentError.value(
        intraPageFraction,
        'intraPageFraction',
        'must be within the closed interval 0..1',
      );
    }
    return 'page:$pageIndex:${intraPageFraction.toStringAsFixed(6)}';
  }

  static MangaProgressLocator? tryParse(String value) {
    final parts = value.split(':');
    if (parts.length != 3 || parts.first != 'page') {
      return null;
    }
    final pageIndex = int.tryParse(parts[1]);
    final fraction = double.tryParse(parts[2]);
    if (pageIndex == null ||
        pageIndex < 0 ||
        fraction == null ||
        !fraction.isFinite ||
        fraction < 0 ||
        fraction > 1) {
      return null;
    }
    return MangaProgressLocator(
      pageIndex: pageIndex,
      intraPageFraction: fraction,
    );
  }
}
