import 'dart:ui' as ui;
import 'dart:typed_data';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../../manga/domain/manga_page.dart';
import '../domain/manga_manifest.dart';

final class FlutterMangaImageDecoder implements MangaImageDecoder {
  const FlutterMangaImageDecoder();

  @override
  Future<MangaImageMetadata> decode(Uint8List bytes) async {
    final type = _detectType(bytes);
    if (type == null) {
      throw AppFailure.fromCode(AppErrorCode.mangaInvalidSource);
    }
    ui.Codec? codec;
    try {
      codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final width = frame.image.width;
      final height = frame.image.height;
      frame.image.dispose();
      if (width <= 0 || height <= 0) throw const FormatException();
      return MangaImageMetadata(type: type, width: width, height: height);
    } on Object {
      throw AppFailure.fromCode(AppErrorCode.mangaInvalidSource);
    } finally {
      codec?.dispose();
    }
  }

  static MangaImageType? _detectType(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return MangaImageType.jpeg;
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0d &&
        bytes[5] == 0x0a &&
        bytes[6] == 0x1a &&
        bytes[7] == 0x0a) {
      return MangaImageType.png;
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return MangaImageType.webp;
    }
    return null;
  }
}
