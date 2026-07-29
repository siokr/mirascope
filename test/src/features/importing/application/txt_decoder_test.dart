import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/importing/application/txt_decoder.dart';
import 'package:mirascope/src/features/importing/domain/decoded_txt.dart';
import 'package:mirascope/src/features/importing/domain/txt_encoding.dart';

void main() {
  final decoder = TxtDecoder(gb18030Decoder: _FakeGb18030Decoder());

  test('ASCII is deterministically identified as UTF-8', () async {
    final result = await decoder.detectAndDecode(
      Uint8List.fromList(ascii.encode('Chapter 1\r\nText')),
    );

    expect(result, isA<DecodedTxt>());
    final decoded = result as DecodedTxt;
    expect(decoded.encoding, TxtEncoding.utf8);
    expect(decoded.text, 'Chapter 1\nText');
    expect(decoded.userSelectedEncoding, isFalse);
  });

  test('UTF-8 BOM is removed and malformed UTF-8 is not replaced', () async {
    final valid = await decoder.detectAndDecode(
      Uint8List.fromList(<int>[0xef, 0xbb, 0xbf, ...utf8.encode('正文')]),
    );
    final invalid = await decoder.decodeAs(
      Uint8List.fromList(<int>[0xc3, 0x28]),
      TxtEncoding.utf8,
    );

    expect((valid as DecodedTxt).text, '正文');
    expect(valid.encoding, TxtEncoding.utf8);
    expect(invalid, isA<TxtDecodingFailed>());
    expect((invalid as TxtDecodingFailed).failure.code, 'decode_failed');
  });

  test('UTF-16 LE and BE BOM decode strict surrogate pairs', () async {
    final littleEndian = await decoder.detectAndDecode(
      Uint8List.fromList(<int>[0xff, 0xfe, 0x41, 0x00, 0x3d, 0xd8, 0x00, 0xde]),
    );
    final bigEndian = await decoder.detectAndDecode(
      Uint8List.fromList(<int>[0xfe, 0xff, 0x00, 0x41, 0xd8, 0x3d, 0xde, 0x00]),
    );

    expect((littleEndian as DecodedTxt).text, 'A😀');
    expect(littleEndian.encoding, TxtEncoding.utf16le);
    expect((bigEndian as DecodedTxt).text, 'A😀');
    expect(bigEndian.encoding, TxtEncoding.utf16be);
  });

  test('odd UTF-16 bytes and unpaired surrogates fail strictly', () async {
    final odd = await decoder.detectAndDecode(
      Uint8List.fromList(<int>[0xff, 0xfe, 0x41]),
    );
    final unpaired = await decoder.decodeAs(
      Uint8List.fromList(<int>[0x00, 0xd8]),
      TxtEncoding.utf16le,
    );

    expect((odd as TxtDecodingFailed).failure.code, 'decode_failed');
    expect((unpaired as TxtDecodingFailed).failure.code, 'decode_failed');
  });

  test('valid GB18030 structure is decoded by the platform adapter', () async {
    final result = await decoder.detectAndDecode(
      Uint8List.fromList(<int>[0xd6, 0xd0, 0xce, 0xc4]),
    );

    expect(result, isA<DecodedTxt>());
    expect((result as DecodedTxt).encoding, TxtEncoding.gb18030);
    expect(result.text, '中文');
  });

  test('GB18030 validator accepts two and four byte forms', () {
    expect(isValidGb18030(<int>[0x41, 0x81, 0x40]), isTrue);
    expect(isValidGb18030(<int>[0x81, 0x30, 0x81, 0x30]), isTrue);
    expect(isValidGb18030(<int>[0x81]), isFalse);
    expect(isValidGb18030(<int>[0x81, 0x7f]), isFalse);
    expect(isValidGb18030(<int>[0x81, 0x30, 0x81]), isFalse);
  });

  test('unknown bytes require explicit user selection', () async {
    final result = await decoder.detectAndDecode(
      Uint8List.fromList(<int>[0x80, 0xff]),
    );

    expect(result, isA<TxtEncodingChoiceRequired>());
    final choice = result as TxtEncodingChoiceRequired;
    expect(choice.failure.code, 'encoding_unknown');
    expect(choice.supportedEncodings, TxtEncoding.values);
  });

  test(
    'manual encoding is recorded and invalid choice can be retried',
    () async {
      final valid = await decoder.decodeAs(
        Uint8List.fromList(<int>[0xd6, 0xd0, 0xce, 0xc4]),
        TxtEncoding.gb18030,
      );
      final invalid = await decoder.decodeAs(
        Uint8List.fromList(<int>[0x81]),
        TxtEncoding.gb18030,
      );

      expect((valid as DecodedTxt).userSelectedEncoding, isTrue);
      expect((invalid as TxtDecodingFailed).failure.code, 'decode_failed');
    },
  );

  test('normalization preserves paragraphs and Chinese typography', () {
    const original = '\uFEFF第一段\r\n\r\n第二段\r繁體，ＡＢＣ。';

    expect(normalizeTxt(original), '第一段\n\n第二段\n繁體，ＡＢＣ。');
  });

  test('blank and control-only content is rejected', () async {
    final blank = await decoder.detectAndDecode(
      Uint8List.fromList(utf8.encode(' \r\n\t　')),
    );
    final controls = await decoder.detectAndDecode(
      Uint8List.fromList(<int>[0x00, 0x01, 0x02]),
    );

    expect((blank as TxtDecodingFailed).failure.code, 'no_readable_content');
    expect((controls as TxtDecodingFailed).failure.code, 'no_readable_content');
  });

  test('preview limits code points without splitting surrogate pairs', () {
    final text = '${'a' * 1999}😀tail';
    final preview = txtPreview(text);

    expect(preview.runes.length, 2000);
    expect(preview.endsWith('😀'), isTrue);
  });
}

final class _FakeGb18030Decoder implements Gb18030Decoder {
  @override
  Future<String> decode(List<int> bytes) async {
    if (_equals(bytes, <int>[0xd6, 0xd0, 0xce, 0xc4])) {
      return '中文';
    }
    if (_equals(bytes, <int>[0x81, 0x30, 0x81, 0x30])) {
      return '𠀀';
    }
    throw const FormatException('Unsupported test fixture');
  }
}

bool _equals(List<int> first, List<int> second) {
  if (first.length != second.length) {
    return false;
  }
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) {
      return false;
    }
  }
  return true;
}
