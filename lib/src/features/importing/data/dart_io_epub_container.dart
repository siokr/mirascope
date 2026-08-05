import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/epub_container.dart';

final class DartIoEpubContainer implements EpubContainer {
  DartIoEpubContainer._({
    required this._input,
    required this._files,
    required List<EpubContainerEntry> entries,
    required this._budget,
  }) : _entries = List.unmodifiable(entries);

  final InputFileStream _input;
  final Map<String, ArchiveFile> _files;
  final List<EpubContainerEntry> _entries;
  final EpubContainerBudget _budget;
  var _closed = false;

  static Future<DartIoEpubContainer> open(
    String sourcePath, {
    EpubContainerBudget budget = const EpubContainerBudget(),
  }) async {
    InputFileStream? input;
    try {
      input = InputFileStream(sourcePath);
      final decoder = ZipDecoder();
      final archive = decoder.decodeStream(input);
      final headers = decoder.directory.fileHeaders;
      if (headers.isEmpty ||
          headers.length != decoder.directory.totalCentralDirectoryEntries) {
        throw AppFailure.fromCode(AppErrorCode.epubInvalidContainer);
      }
      if (decoder.directory.numberOfThisDisk != 0 ||
          decoder.directory.diskWithTheStartOfTheCentralDirectory != 0) {
        throw AppFailure.fromCode(AppErrorCode.epubInvalidContainer);
      }
      if (headers.length > budget.maximumEntryCount) {
        throw AppFailure.fromCode(AppErrorCode.epubResourceLimit);
      }

      final files = <String, ArchiveFile>{};
      final seenPaths = <String>{};
      final entries = <EpubContainerEntry>[];
      var totalSize = 0;
      for (final header in headers) {
        final normalized = normalizeEpubContainerPath(header.filename);
        if (!seenPaths.add(normalized)) {
          throw AppFailure.fromCode(AppErrorCode.epubUnsafePath);
        }

        final file = archive.find(header.filename);
        if (file == null || file.isSymbolicLink) {
          throw AppFailure.fromCode(AppErrorCode.epubUnsafePath);
        }
        if (!file.isFile) {
          continue;
        }

        _validateEntryBudget(header, budget);
        totalSize += header.uncompressedSize;
        if (totalSize > budget.maximumTotalSize) {
          throw AppFailure.fromCode(AppErrorCode.epubResourceLimit);
        }

        files[normalized] = file;
        entries.add(
          EpubContainerEntry(
            path: normalized,
            uncompressedSize: header.uncompressedSize,
            compressedSize: header.compressedSize,
          ),
        );
      }

      return DartIoEpubContainer._(
        input: input,
        files: files,
        entries: entries,
        budget: budget,
      );
    } on AppFailure {
      await input?.close();
      rethrow;
    } on Object {
      await input?.close();
      throw AppFailure.fromCode(AppErrorCode.epubInvalidContainer);
    }
  }

  @override
  List<EpubContainerEntry> get entries => _entries;

  @override
  bool contains(String path) {
    _ensureOpen();
    return _files.containsKey(normalizeEpubContainerPath(path));
  }

  @override
  Future<Uint8List> readBytes(String path) async {
    _ensureOpen();
    final normalized = normalizeEpubContainerPath(path);
    final file = _files[normalized];
    if (file == null) {
      throw AppFailure.fromCode(AppErrorCode.epubResourceMissing);
    }

    try {
      final output = _BudgetedOutputStream(_budget.maximumEntrySize);
      file.decompress(output);
      final bytes = output.getBytes();
      if (bytes.length != file.size) {
        throw AppFailure.fromCode(AppErrorCode.epubInvalidContainer);
      }
      if (file.crc32 != null && getCrc32(bytes) != file.crc32) {
        throw AppFailure.fromCode(AppErrorCode.epubInvalidContainer);
      }
      return bytes;
    } on AppFailure {
      rethrow;
    } on Object {
      throw AppFailure.fromCode(AppErrorCode.epubInvalidContainer);
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
      throw StateError('EPUB container is closed');
    }
  }
}

String normalizeEpubContainerPath(String rawPath) {
  if (rawPath.isEmpty || rawPath.contains('\u0000') || rawPath.contains('\\')) {
    throw AppFailure.fromCode(AppErrorCode.epubUnsafePath);
  }

  late String decoded;
  try {
    decoded = Uri.decodeComponent(rawPath);
  } on Object {
    throw AppFailure.fromCode(AppErrorCode.epubUnsafePath);
  }
  if (decoded.isEmpty || decoded.startsWith('/') || decoded.contains('\\')) {
    throw AppFailure.fromCode(AppErrorCode.epubUnsafePath);
  }
  if (RegExp(r'^[A-Za-z]:').hasMatch(decoded)) {
    throw AppFailure.fromCode(AppErrorCode.epubUnsafePath);
  }

  if (decoded.endsWith('/')) {
    decoded = decoded.substring(0, decoded.length - 1);
  }
  final segments = decoded.split('/');
  if (segments.any(
    (segment) => segment.isEmpty || segment == '.' || segment == '..',
  )) {
    throw AppFailure.fromCode(AppErrorCode.epubUnsafePath);
  }
  return segments.join('/');
}

void _validateEntryBudget(ZipFileHeader header, EpubContainerBudget budget) {
  final expanded = header.uncompressedSize;
  final compressed = header.compressedSize;
  if (expanded < 0 || compressed < 0 || expanded > budget.maximumEntrySize) {
    throw AppFailure.fromCode(AppErrorCode.epubResourceLimit);
  }
  if (expanded > 0 && compressed == 0) {
    throw AppFailure.fromCode(AppErrorCode.epubResourceLimit);
  }
  if (compressed > 0 &&
      expanded > compressed * budget.maximumCompressionRatio) {
    throw AppFailure.fromCode(AppErrorCode.epubResourceLimit);
  }
}

final class _BudgetedOutputStream extends OutputStream {
  _BudgetedOutputStream(this.maximumSize)
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
  void writeByte(int value) => writeBytes(<int>[value]);

  @override
  void writeBytes(List<int> bytes, {int? length}) {
    final count = length ?? bytes.length;
    if (count < 0 ||
        count > bytes.length ||
        this.length + count > maximumSize) {
      throw AppFailure.fromCode(AppErrorCode.epubResourceLimit);
    }
    _builder.add(bytes.take(count).toList(growable: false));
  }

  @override
  void writeStream(InputStream stream) {
    while (!stream.isEOS) {
      final remaining = maximumSize - length;
      if (remaining == 0) {
        throw AppFailure.fromCode(AppErrorCode.epubResourceLimit);
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
