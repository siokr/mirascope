import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/manga/domain/manga_page.dart';
import 'package:mirascope/src/features/manga/domain/manga_progress_locator.dart';
import 'package:mirascope/src/features/manga/domain/manga_reader_preference.dart';

void main() {
  test('manga enums use stable storage values', () {
    expect(MangaImageType.webp.storageValue, 'image/webp');
    expect(MangaReadingMode.horizontal.storageValue, 'horizontal');
    expect(PageTurnDirection.rightToLeft.storageValue, 'rightToLeft');
  });

  test('manga enums reject unknown storage values', () {
    expect(
      () => MangaImageType.fromStorageValue('image/gif'),
      throwsArgumentError,
    );
    expect(
      () => MangaReadingMode.fromStorageValue('doublePage'),
      throwsArgumentError,
    );
    expect(
      () => PageTurnDirection.fromStorageValue('topToBottom'),
      throwsArgumentError,
    );
  });

  test('manga progress locator round-trips semantic page position', () {
    const locator = MangaProgressLocator(
      pageIndex: 12,
      intraPageFraction: 0.375,
    );

    final restored = MangaProgressLocator.tryParse(locator.encode());

    expect(restored?.pageIndex, 12);
    expect(restored?.intraPageFraction, 0.375);
  });

  test('manga progress locator rejects invalid positions', () {
    expect(MangaProgressLocator.tryParse('paragraph:1'), isNull);
    expect(MangaProgressLocator.tryParse('page:-1:0.5'), isNull);
    expect(MangaProgressLocator.tryParse('page:1:1.1'), isNull);
    expect(
      () => const MangaProgressLocator(
        pageIndex: 0,
        intraPageFraction: double.nan,
      ).encode(),
      throwsArgumentError,
    );
  });
}
