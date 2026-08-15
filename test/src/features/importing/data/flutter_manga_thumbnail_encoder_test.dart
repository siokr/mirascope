import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/importing/data/flutter_manga_image_decoder.dart';
import 'package:mirascope/src/features/importing/data/flutter_manga_thumbnail_encoder.dart';

import '../../../../support/manga_test_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('produces a genuinely decodable PNG thumbnail', () async {
    final bytes = await const FlutterMangaThumbnailEncoder().encode(
      generatedMangaPng(),
    );
    final metadata = await const FlutterMangaImageDecoder().decode(bytes);
    expect(metadata.width, 1);
    expect(metadata.height, 1);
  });
}
