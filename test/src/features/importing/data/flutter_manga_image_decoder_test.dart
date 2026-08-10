import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/data/flutter_manga_image_decoder.dart';
import 'package:mirascope/src/features/manga/domain/manga_page.dart';

import '../../../../support/manga_test_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('really decodes PNG pixels and dimensions', () async {
    final metadata = await const FlutterMangaImageDecoder().decode(
      generatedMangaPng(),
    );
    expect(metadata.type, MangaImageType.png);
    expect(metadata.width, 1);
    expect(metadata.height, 1);
  });

  test('rejects a forged PNG signature that cannot decode', () async {
    final forged = Uint8List.fromList([
      0x89,
      0x50,
      0x4e,
      0x47,
      0x0d,
      0x0a,
      0x1a,
      0x0a,
      1,
      2,
      3,
    ]);
    await expectLater(
      const FlutterMangaImageDecoder().decode(forged),
      throwsA(isA<AppFailure>()),
    );
  });

  test('rejects unsupported image data', () async {
    await expectLater(
      const FlutterMangaImageDecoder().decode(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<AppFailure>()),
    );
  });
}
