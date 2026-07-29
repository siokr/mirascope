import '../../../core/errors/app_failure.dart';
import 'txt_encoding.dart';

sealed class TxtDecodingResult {
  const TxtDecodingResult();
}

final class DecodedTxt extends TxtDecodingResult {
  const DecodedTxt({
    required this.encoding,
    required this.text,
    required this.preview,
    required this.userSelectedEncoding,
  });

  final TxtEncoding encoding;
  final String text;
  final String preview;
  final bool userSelectedEncoding;
}

final class TxtEncodingChoiceRequired extends TxtDecodingResult {
  const TxtEncodingChoiceRequired(this.failure);

  final AppFailure failure;
  List<TxtEncoding> get supportedEncodings => TxtEncoding.values;
}

final class TxtDecodingFailed extends TxtDecodingResult {
  const TxtDecodingFailed(this.failure);

  final AppFailure failure;
}
