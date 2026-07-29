import '../domain/decoded_txt.dart';
import '../domain/txt_encoding.dart';
import '../domain/txt_source_candidate.dart';
import '../domain/txt_source_reader.dart';
import 'txt_decoder.dart';

final class DecodeTxtSource {
  const DecodeTxtSource({required this.sourceReader, required this.decoder});

  final TxtSourceReader sourceReader;
  final TxtDecoder decoder;

  Future<TxtDecodingResult> call(
    TxtSourceCandidate candidate, {
    TxtEncoding? selectedEncoding,
  }) async {
    final bytes = await sourceReader.read(candidate);
    if (selectedEncoding case final encoding?) {
      return decoder.decodeAs(bytes, encoding);
    }
    return decoder.detectAndDecode(bytes);
  }
}
