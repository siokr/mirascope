import 'dart:convert';

String decodeEpubMarkup(List<int> bytes) {
  if (bytes.length >= 2) {
    final littleEndian =
        (bytes[0] == 0xff && bytes[1] == 0xfe) ||
        (bytes[0] == 0x3c && bytes[1] == 0x00);
    final bigEndian =
        (bytes[0] == 0xfe && bytes[1] == 0xff) ||
        (bytes[0] == 0x00 && bytes[1] == 0x3c);
    if (littleEndian || bigEndian) {
      final start = (bytes[0] == 0xff || bytes[0] == 0xfe) ? 2 : 0;
      if ((bytes.length - start).isOdd) {
        throw const FormatException('Invalid UTF-16 byte length');
      }
      final codeUnits = <int>[];
      for (var index = start; index < bytes.length; index += 2) {
        codeUnits.add(
          littleEndian
              ? bytes[index] | (bytes[index + 1] << 8)
              : (bytes[index] << 8) | bytes[index + 1],
        );
      }
      return String.fromCharCodes(codeUnits);
    }
  }
  return utf8.decode(bytes, allowMalformed: false);
}
