import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/importing/application/decode_txt_source.dart';
import 'package:mirascope/src/features/importing/application/txt_decoder.dart';
import 'package:mirascope/src/features/importing/domain/decoded_txt.dart';
import 'package:mirascope/src/features/importing/domain/txt_encoding.dart';
import 'package:mirascope/src/features/importing/domain/txt_source_candidate.dart';
import 'package:mirascope/src/features/importing/domain/txt_source_reader.dart';

void main() {
  final candidate = TxtSourceCandidate(
    path: r'C:\books\novel.txt',
    fileSize: 6,
    modifiedAt: DateTime.utc(2026, 7, 29),
    fingerprint: 'sha256:test:6',
  );

  test('automatic decoding uses the bytes for the same candidate', () async {
    final reader = _FakeReader(Uint8List.fromList(utf8.encode('正文')));
    final useCase = DecodeTxtSource(
      sourceReader: reader,
      decoder: TxtDecoder(gb18030Decoder: _RejectingGb18030Decoder()),
    );

    final result = await useCase(candidate);

    expect((result as DecodedTxt).encoding, TxtEncoding.utf8);
    expect(result.text, '正文');
    expect(reader.candidates, <TxtSourceCandidate>[candidate]);
  });

  test('selected encoding takes the strict manual path', () async {
    final useCase = DecodeTxtSource(
      sourceReader: _FakeReader(
        Uint8List.fromList(<int>[0xff, 0xfe, 0x41, 0x00]),
      ),
      decoder: TxtDecoder(gb18030Decoder: _RejectingGb18030Decoder()),
    );

    final result = await useCase(
      candidate,
      selectedEncoding: TxtEncoding.utf16le,
    );

    expect((result as DecodedTxt).text, 'A');
    expect(result.userSelectedEncoding, isTrue);
  });
}

final class _FakeReader implements TxtSourceReader {
  _FakeReader(this.bytes);

  final Uint8List bytes;
  final candidates = <TxtSourceCandidate>[];

  @override
  Future<Uint8List> read(TxtSourceCandidate candidate) async {
    candidates.add(candidate);
    return bytes;
  }
}

final class _RejectingGb18030Decoder implements Gb18030Decoder {
  @override
  Future<String> decode(List<int> bytes) async {
    throw const FormatException('not used');
  }
}
