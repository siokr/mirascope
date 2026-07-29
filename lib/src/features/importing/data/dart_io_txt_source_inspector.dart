import 'dart:io';

import 'package:crypto/crypto.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/txt_source_candidate.dart';

typedef SourceStatReader = Future<FileStat> Function(String path);
typedef SourceByteStreamReader = Stream<List<int>> Function(String path);

final class DartIoTxtSourceInspector implements TxtSourceInspector {
  DartIoTxtSourceInspector({
    SourceStatReader? readStat,
    SourceByteStreamReader? openByteStream,
  }) : _readStat = readStat ?? FileStat.stat,
       _openByteStream = openByteStream ?? ((path) => File(path).openRead());

  final SourceStatReader _readStat;
  final SourceByteStreamReader _openByteStream;

  @override
  Future<TxtSourceCandidate> inspect(String path) async {
    try {
      final before = await _readStat(path);
      if (before.type != FileSystemEntityType.file) {
        throw AppFailure.fromCode(AppErrorCode.fileNotFound);
      }
      if (before.size == 0) {
        throw AppFailure.fromCode(AppErrorCode.emptyFile);
      }

      final digest = await sha256.bind(_openByteStream(path)).single;
      final after = await _readStat(path);
      if (after.type != FileSystemEntityType.file) {
        throw AppFailure.fromCode(AppErrorCode.fileNotFound);
      }
      if (before.size != after.size ||
          before.modified.toUtc() != after.modified.toUtc()) {
        throw AppFailure.fromCode(AppErrorCode.sourceChanged);
      }

      return TxtSourceCandidate(
        path: path,
        fileSize: after.size,
        modifiedAt: after.modified.toUtc(),
        fingerprint: 'sha256:$digest:${after.size}',
      );
    } on AppFailure {
      rethrow;
    } on FileSystemException catch (error) {
      throw mapFileSystemFailure(error);
    } on Object {
      throw AppFailure.fromCode(AppErrorCode.storageFailed);
    }
  }
}

AppFailure mapFileSystemFailure(FileSystemException error) {
  return switch (error.osError?.errorCode) {
    2 || 3 => AppFailure.fromCode(AppErrorCode.fileNotFound),
    5 || 13 => AppFailure.fromCode(AppErrorCode.filePermissionDenied),
    _ => AppFailure.fromCode(AppErrorCode.storageFailed),
  };
}
