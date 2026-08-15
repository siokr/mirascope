import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/derived_manga_store.dart';

final class FlutterMangaThumbnailEncoder implements MangaThumbnailEncoder {
  const FlutterMangaThumbnailEncoder({this.maximumWidth = 320});

  final int maximumWidth;

  @override
  Future<Uint8List> encode(Uint8List sourceBytes) async {
    ui.Codec? codec;
    ui.Image? image;
    try {
      codec = await ui.instantiateImageCodec(
        sourceBytes,
        targetWidth: maximumWidth,
        allowUpscaling: false,
      );
      final frame = await codec.getNextFrame();
      image = frame.image;
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw const FormatException('thumbnail encoding failed');
      }
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } on Object {
      throw AppFailure.fromCode(AppErrorCode.storageFailed);
    } finally {
      image?.dispose();
      codec?.dispose();
    }
  }
}
