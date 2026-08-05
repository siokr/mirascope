import 'dart:io';

import 'package:crypto/crypto.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/epub_source_candidate.dart';
import 'dart_io_txt_source_inspector.dart' show mapFileSystemFailure;

typedef EpubSourceStatReader = Future<FileStat> Function(String path);
typedef EpubSourceByteStreamReader = Stream<List<int>> Function(String path);
typedef EpubSourceHeaderReader = Future<List<int>> Function(String path);

final class DartIoEpubSourceInspector implements EpubSourceInspector {
  DartIoEpubSourceInspector({
    EpubSourceStatReader? readStat,
    EpubSourceByteStreamReader? openByteStream,
    EpubSourceHeaderReader? readHeader,
    this.maximumFileSize = defaultMaximumFileSize,
  }) : _readStat = readStat ?? FileStat.stat,
       _openByteStream = openByteStream ?? ((path) => File(path).openRead()),
       _readHeader = readHeader ?? _readFileHeader;

  static const defaultMaximumFileSize = 100 * 1024 * 1024;

  final EpubSourceStatReader _readStat;
  final EpubSourceByteStreamReader _openByteStream;
  final EpubSourceHeaderReader _readHeader;
  final int maximumFileSize;

  @override
  Future<EpubSourceCandidate> inspect(String path) async {
    try {
      if (!_hasEpubExtension(path)) {
        throw AppFailure.fromCode(AppErrorCode.epubInvalidContainer);
      }

      final before = await _readStat(path);
      if (before.type != FileSystemEntityType.file) {
        throw AppFailure.fromCode(AppErrorCode.fileNotFound);
      }
      if (before.size == 0) {
        throw AppFailure.fromCode(AppErrorCode.emptyFile);
      }
      if (before.size > maximumFileSize) {
        throw AppFailure.fromCode(AppErrorCode.epubResourceLimit);
      }

      final header = await _readHeader(path);
      if (!_hasZipLocalFileHeader(header)) {
        throw AppFailure.fromCode(AppErrorCode.epubInvalidContainer);
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

      return EpubSourceCandidate(
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

  static Future<List<int>> _readFileHeader(String path) async {
    return File(path).openRead(0, 4).expand((chunk) => chunk).toList();
  }

  static bool _hasEpubExtension(String path) =>
      path.toLowerCase().endsWith('.epub');

  static bool _hasZipLocalFileHeader(List<int> bytes) =>
      bytes.length >= 4 &&
      bytes[0] == 0x50 &&
      bytes[1] == 0x4b &&
      bytes[2] == 0x03 &&
      bytes[3] == 0x04;
}
