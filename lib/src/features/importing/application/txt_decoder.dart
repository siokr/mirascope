import 'dart:convert';
import 'dart:typed_data';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/decoded_txt.dart';
import '../domain/txt_encoding.dart';

final class TxtDecoder {
  const TxtDecoder({required this.gb18030Decoder});

  final Gb18030Decoder gb18030Decoder;

  Future<TxtDecodingResult> detectAndDecode(Uint8List bytes) async {
    if (_startsWith(bytes, const [0xef, 0xbb, 0xbf])) {
      return _decodeKnown(
        bytes.sublist(3),
        TxtEncoding.utf8,
        userSelected: false,
      );
    }
    if (_startsWith(bytes, const [0xff, 0xfe])) {
      return _decodeKnown(
        bytes.sublist(2),
        TxtEncoding.utf16le,
        userSelected: false,
      );
    }
    if (_startsWith(bytes, const [0xfe, 0xff])) {
      return _decodeKnown(
        bytes.sublist(2),
        TxtEncoding.utf16be,
        userSelected: false,
      );
    }

    try {
      final decoded = utf8.decode(bytes, allowMalformed: false);
      return _success(decoded, TxtEncoding.utf8, userSelected: false);
    } on FormatException {
      // Continue with deterministic GB18030 validation.
    }

    if (isValidGb18030(bytes)) {
      try {
        final decoded = await gb18030Decoder.decode(bytes);
        return _success(decoded, TxtEncoding.gb18030, userSelected: false);
      } on Object {
        return TxtEncodingChoiceRequired(
          AppFailure.fromCode(AppErrorCode.encodingUnknown),
        );
      }
    }

    return TxtEncodingChoiceRequired(
      AppFailure.fromCode(AppErrorCode.encodingUnknown),
    );
  }

  Future<TxtDecodingResult> decodeAs(Uint8List bytes, TxtEncoding encoding) {
    final payload = switch (encoding) {
      TxtEncoding.utf8 when _startsWith(bytes, const [0xef, 0xbb, 0xbf]) =>
        bytes.sublist(3),
      TxtEncoding.utf16le when _startsWith(bytes, const [0xff, 0xfe]) =>
        bytes.sublist(2),
      TxtEncoding.utf16be when _startsWith(bytes, const [0xfe, 0xff]) =>
        bytes.sublist(2),
      _ => bytes,
    };
    return _decodeKnown(payload, encoding, userSelected: true);
  }

  Future<TxtDecodingResult> _decodeKnown(
    Uint8List bytes,
    TxtEncoding encoding, {
    required bool userSelected,
  }) async {
    try {
      final decoded = switch (encoding) {
        TxtEncoding.utf8 => utf8.decode(bytes, allowMalformed: false),
        TxtEncoding.utf16le => _decodeUtf16(bytes, littleEndian: true),
        TxtEncoding.utf16be => _decodeUtf16(bytes, littleEndian: false),
        TxtEncoding.gb18030 => await _decodeGb18030Strict(bytes),
      };
      return _success(decoded, encoding, userSelected: userSelected);
    } on Object {
      return TxtDecodingFailed(AppFailure.fromCode(AppErrorCode.decodeFailed));
    }
  }

  Future<String> _decodeGb18030Strict(Uint8List bytes) {
    if (!isValidGb18030(bytes)) {
      throw const FormatException('Invalid GB18030 byte sequence');
    }
    return gb18030Decoder.decode(bytes);
  }

  TxtDecodingResult _success(
    String decoded,
    TxtEncoding encoding, {
    required bool userSelected,
  }) {
    final normalized = normalizeTxt(decoded);
    if (normalized.contains('\uFFFD') || !hasReadableContent(normalized)) {
      return TxtDecodingFailed(
        AppFailure.fromCode(AppErrorCode.noReadableContent),
      );
    }
    return DecodedTxt(
      encoding: encoding,
      text: normalized,
      preview: txtPreview(normalized),
      userSelectedEncoding: userSelected,
    );
  }
}

String _decodeUtf16(Uint8List bytes, {required bool littleEndian}) {
  if (bytes.length.isOdd) {
    throw const FormatException('UTF-16 requires complete code units');
  }

  final codeUnits = <int>[];
  for (var index = 0; index < bytes.length; index += 2) {
    final first = bytes[index];
    final second = bytes[index + 1];
    codeUnits.add(littleEndian ? first | (second << 8) : (first << 8) | second);
  }

  final codePoints = <int>[];
  for (var index = 0; index < codeUnits.length; index++) {
    final unit = codeUnits[index];
    if (unit >= 0xd800 && unit <= 0xdbff) {
      if (index + 1 >= codeUnits.length) {
        throw const FormatException('Unpaired UTF-16 high surrogate');
      }
      final low = codeUnits[++index];
      if (low < 0xdc00 || low > 0xdfff) {
        throw const FormatException('Unpaired UTF-16 high surrogate');
      }
      codePoints.add(0x10000 + ((unit - 0xd800) << 10) + (low - 0xdc00));
    } else if (unit >= 0xdc00 && unit <= 0xdfff) {
      throw const FormatException('Unpaired UTF-16 low surrogate');
    } else {
      codePoints.add(unit);
    }
  }
  return String.fromCharCodes(codePoints);
}

bool isValidGb18030(List<int> bytes) {
  var index = 0;
  while (index < bytes.length) {
    final first = bytes[index];
    if (first <= 0x7f) {
      index++;
      continue;
    }
    if (first < 0x81 || first > 0xfe || index + 1 >= bytes.length) {
      return false;
    }

    final second = bytes[index + 1];
    if (second >= 0x40 && second <= 0xfe && second != 0x7f) {
      index += 2;
      continue;
    }
    if (second < 0x30 ||
        second > 0x39 ||
        index + 3 >= bytes.length ||
        bytes[index + 2] < 0x81 ||
        bytes[index + 2] > 0xfe ||
        bytes[index + 3] < 0x30 ||
        bytes[index + 3] > 0x39) {
      return false;
    }
    index += 4;
  }
  return true;
}

String normalizeTxt(String value) {
  final withoutBom = value.startsWith('\uFEFF') ? value.substring(1) : value;
  return withoutBom.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
}

bool hasReadableContent(String value) {
  for (final rune in value.runes) {
    final isWhitespace =
        rune == 0x09 ||
        rune == 0x0a ||
        rune == 0x0d ||
        rune == 0x20 ||
        rune == 0x3000;
    final isControl = rune < 0x20 || (rune >= 0x7f && rune <= 0x9f);
    if (!isWhitespace && !isControl) {
      return true;
    }
  }
  return false;
}

String txtPreview(String value, {int maxCodePoints = 2000}) {
  return String.fromCharCodes(value.runes.take(maxCodePoints));
}

bool _startsWith(List<int> bytes, List<int> prefix) {
  if (bytes.length < prefix.length) {
    return false;
  }
  for (var index = 0; index < prefix.length; index++) {
    if (bytes[index] != prefix[index]) {
      return false;
    }
  }
  return true;
}
