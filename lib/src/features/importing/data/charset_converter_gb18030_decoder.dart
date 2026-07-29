import 'dart:typed_data';

import 'package:charset_converter/charset_converter.dart';

import '../domain/txt_encoding.dart';

final class CharsetConverterGb18030Decoder implements Gb18030Decoder {
  const CharsetConverterGb18030Decoder();

  @override
  Future<String> decode(List<int> bytes) {
    return CharsetConverter.decode('GB18030', Uint8List.fromList(bytes));
  }
}
