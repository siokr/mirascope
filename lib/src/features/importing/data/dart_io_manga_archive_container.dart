import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/manga_archive_container.dart';

final class DartIoMangaArchiveContainer implements MangaArchiveContainer {
  DartIoMangaArchiveContainer._({
    required this._input,
    required this._files,
    required List<MangaArchiveEntry> entries,
    required this._budget,
  }) : _entries = List.unmodifiable(entries);

  final InputFileStream _input;
  final Map<String, ArchiveFile> _files;
  final List<MangaArchiveEntry> _entries;
  final MangaArchiveBudget _budget;
  var _closed = false;

  static Future<DartIoMangaArchiveContainer> open(
    String sourcePath, {
    MangaArchiveBudget budget = const MangaArchiveBudget(),
  }) async {
    InputFileStream? input;
    try {
      final archiveSize = await File(sourcePath).length();
      if (archiveSize <= 0 || archiveSize > budget.maximumArchiveSize) {
        throw AppFailure.fromCode(AppErrorCode.mangaResourceLimit);
      }
      input = InputFileStream(sourcePath);
      final decoder = ZipDecoder();
      final archive = decoder.decodeStream(input);
      final headers = decoder.directory.fileHeaders;
      if (headers.isEmpty ||
          headers.length != decoder.directory.totalCentralDirectoryEntries ||
          decoder.directory.numberOfThisDisk != 0 ||
          decoder.directory.diskWithTheStartOfTheCentralDirectory != 0) {
        throw AppFailure.fromCode(AppErrorCode.mangaInvalidContainer);
      }
      if (headers.length > budget.maximumEntryCount) {
        throw AppFailure.fromCode(AppErrorCode.mangaResourceLimit);
      }

      final files = <String, ArchiveFile>{};
      final pathKinds = <String, bool>{};
      final entries = <MangaArchiveEntry>[];
      var totalSize = 0;
      for (final header in headers) {
        if ((header.generalPurposeBitFlag & 0x1) != 0 ||
            header.compressionMethod == 99) {
          throw AppFailure.fromCode(AppErrorCode.mangaEncryptedArchive);
        }
        if (header.compressionMethod != 0 && header.compressionMethod != 8) {
          throw AppFailure.fromCode(AppErrorCode.mangaInvalidContainer);
        }
        final normalized = normalizeMangaArchivePath(header.filename);
        final file = archive.find(header.filename);
        if (file == null || file.isSymbolicLink) {
          throw AppFailure.fromCode(AppErrorCode.mangaUnsafePath);
        }
        if (_hasPathConflict(pathKinds, normalized, file.isFile)) {
          throw AppFailure.fromCode(AppErrorCode.mangaUnsafePath);
        }
        pathKinds[normalized] = file.isFile;
        if (!file.isFile) {
          continue;
        }

        _validateBudget(header, budget);
        totalSize += header.uncompressedSize;
        if (totalSize > budget.maximumTotalSize) {
          throw AppFailure.fromCode(AppErrorCode.mangaResourceLimit);
        }
        files[normalized] = file;
        entries.add(
          MangaArchiveEntry(
            path: normalized,
            uncompressedSize: header.uncompressedSize,
            compressedSize: header.compressedSize,
          ),
        );
      }

      return DartIoMangaArchiveContainer._(
        input: input,
        files: files,
        entries: entries,
        budget: budget,
      );
    } on AppFailure {
      await input?.close();
      rethrow;
    } on FileSystemException catch (error) {
      await input?.close();
      throw switch (error.osError?.errorCode) {
        2 || 3 => AppFailure.fromCode(AppErrorCode.fileNotFound),
        5 || 13 => AppFailure.fromCode(AppErrorCode.filePermissionDenied),
        _ => AppFailure.fromCode(AppErrorCode.mangaInvalidContainer),
      };
    } on Object {
      await input?.close();
      throw AppFailure.fromCode(AppErrorCode.mangaInvalidContainer);
    }
  }

  @override
  List<MangaArchiveEntry> get entries => _entries;

  @override
  bool contains(String path) {
    _ensureOpen();
    return _files.containsKey(normalizeMangaArchivePath(path));
  }

  @override
  Future<Uint8List> readBytes(String path) async {
    _ensureOpen();
    final normalized = normalizeMangaArchivePath(path);
    final file = _files[normalized];
    if (file == null) {
      throw AppFailure.fromCode(AppErrorCode.mangaResourceMissing);
    }
    try {
      final output = _MangaBudgetedOutputStream(_budget.maximumEntrySize);
      file.decompress(output);
      final bytes = output.getBytes();
      if (bytes.length != file.size ||
          (file.crc32 != null && getCrc32(bytes) != file.crc32)) {
        throw AppFailure.fromCode(AppErrorCode.mangaInvalidContainer);
      }
      return bytes;
    } on AppFailure {
      rethrow;
    } on Object {
      throw AppFailure.fromCode(AppErrorCode.mangaInvalidContainer);
    }
  }

  @override
  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    await _input.close();
  }

  void _ensureOpen() {
    if (_closed) {
      throw StateError('Manga archive container is closed');
    }
  }
}

String normalizeMangaArchivePath(String rawPath) {
  if (rawPath.isEmpty || rawPath.contains('\u0000') || rawPath.contains('\\')) {
    throw AppFailure.fromCode(AppErrorCode.mangaUnsafePath);
  }
  if (RegExp(r'%(?![0-9A-Fa-f]{2})').hasMatch(rawPath)) {
    throw AppFailure.fromCode(AppErrorCode.mangaUnsafePath);
  }
  late String decoded;
  try {
    decoded = rawPath.replaceAllMapped(
      RegExp(r'(?:%[0-9A-Fa-f]{2})+'),
      (match) => Uri.decodeComponent(match.group(0)!),
    );
  } on Object {
    throw AppFailure.fromCode(AppErrorCode.mangaUnsafePath);
  }
  if (decoded.isEmpty || decoded.startsWith('/') || decoded.contains('\\')) {
    throw AppFailure.fromCode(AppErrorCode.mangaUnsafePath);
  }
  if (RegExp(r'^[A-Za-z]:').hasMatch(decoded)) {
    throw AppFailure.fromCode(AppErrorCode.mangaUnsafePath);
  }
  if (decoded.endsWith('/')) {
    decoded = decoded.substring(0, decoded.length - 1);
  }
  final segments = decoded.split('/');
  if (segments.any(
    (segment) => segment.isEmpty || segment == '.' || segment == '..',
  )) {
    throw AppFailure.fromCode(AppErrorCode.mangaUnsafePath);
  }
  return segments.join('/');
}

bool _hasPathConflict(Map<String, bool> paths, String path, bool isFile) {
  if (paths.containsKey(path)) {
    return true;
  }
  for (final existing in paths.entries) {
    if ((existing.value && path.startsWith('${existing.key}/')) ||
        (isFile && existing.key.startsWith('$path/'))) {
      return true;
    }
  }
  return false;
}

void _validateBudget(ZipFileHeader header, MangaArchiveBudget budget) {
  final expanded = header.uncompressedSize;
  final compressed = header.compressedSize;
  if (expanded < 0 || compressed < 0 || expanded > budget.maximumEntrySize) {
    throw AppFailure.fromCode(AppErrorCode.mangaResourceLimit);
  }
  if (expanded > 0 && compressed == 0) {
    throw AppFailure.fromCode(AppErrorCode.mangaResourceLimit);
  }
  if (compressed > 0 &&
      expanded > compressed * budget.maximumCompressionRatio) {
    throw AppFailure.fromCode(AppErrorCode.mangaResourceLimit);
  }
}

final class _MangaBudgetedOutputStream extends OutputStream {
  _MangaBudgetedOutputStream(this.maximumSize)
    : super(byteOrder: ByteOrder.littleEndian);

  final int maximumSize;
  final BytesBuilder _builder = BytesBuilder(copy: false);

  @override
  int get length => _builder.length;

  @override
  void clear() => _builder.clear();

  @override
  void flush() {}

  @override
  void writeByte(int value) => writeBytes([value]);

  @override
  void writeBytes(List<int> bytes, {int? length}) {
    final count = length ?? bytes.length;
    if (count < 0 ||
        count > bytes.length ||
        this.length + count > maximumSize) {
      throw AppFailure.fromCode(AppErrorCode.mangaResourceLimit);
    }
    _builder.add(bytes.take(count).toList(growable: false));
  }

  @override
  void writeStream(InputStream stream) {
    while (!stream.isEOS) {
      final remaining = maximumSize - length;
      if (remaining == 0) {
        throw AppFailure.fromCode(AppErrorCode.mangaResourceLimit);
      }
      final count = stream.length < remaining ? stream.length : remaining;
      writeBytes(stream.readBytes(count).toUint8List());
    }
  }

  @override
  Uint8List subset(int start, [int? end]) {
    final bytes = _builder.toBytes();
    return Uint8List.sublistView(bytes, start, end);
  }
}
