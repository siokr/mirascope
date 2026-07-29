import 'dart:io';
import 'dart:typed_data';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/txt_source_candidate.dart';
import '../domain/txt_source_reader.dart';
import 'dart_io_txt_source_inspector.dart';

typedef SourceBytesReader = Future<Uint8List> Function(String path);

final class DartIoTxtSourceReader implements TxtSourceReader {
  DartIoTxtSourceReader({
    SourceStatReader? readStat,
    SourceBytesReader? readBytes,
  }) : _readStat = readStat ?? FileStat.stat,
       _readBytes = readBytes ?? ((path) => File(path).readAsBytes());

  final SourceStatReader _readStat;
  final SourceBytesReader _readBytes;

  @override
  Future<Uint8List> read(TxtSourceCandidate candidate) async {
    try {
      final before = await _readStat(candidate.path);
      _verifySameSource(candidate, before);
      final bytes = await _readBytes(candidate.path);
      final after = await _readStat(candidate.path);
      _verifySameSource(candidate, after);
      if (bytes.length != candidate.fileSize) {
        throw AppFailure.fromCode(AppErrorCode.sourceChanged);
      }
      return bytes;
    } on AppFailure {
      rethrow;
    } on FileSystemException catch (error) {
      throw mapFileSystemFailure(error);
    } on Object {
      throw AppFailure.fromCode(AppErrorCode.storageFailed);
    }
  }

  void _verifySameSource(TxtSourceCandidate candidate, FileStat stat) {
    if (stat.type != FileSystemEntityType.file) {
      throw AppFailure.fromCode(AppErrorCode.fileNotFound);
    }
    if (stat.size != candidate.fileSize ||
        stat.modified.toUtc() != candidate.modifiedAt.toUtc()) {
      throw AppFailure.fromCode(AppErrorCode.sourceChanged);
    }
  }
}
