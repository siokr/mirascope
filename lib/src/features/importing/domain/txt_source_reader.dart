import 'dart:typed_data';

import 'txt_source_candidate.dart';

abstract interface class TxtSourceReader {
  Future<Uint8List> read(TxtSourceCandidate candidate);
}
