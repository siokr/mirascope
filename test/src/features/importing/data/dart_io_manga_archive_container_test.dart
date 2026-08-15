import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/data/dart_io_manga_archive_container.dart';
import 'package:mirascope/src/features/importing/domain/manga_archive_container.dart';

import '../../../../support/manga_test_fixture.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'mirascope-manga-container-',
    );
  });

  tearDown(() => temporaryDirectory.delete(recursive: true));

  test('opens a valid CBZ and reads exact-case entries on demand', () async {
    final source = await _writeBytes(temporaryDirectory, basicMangaArchive());
    final container = await DartIoMangaArchiveContainer.open(source.path);
    addTearDown(container.close);

    expect(container.entries, hasLength(6));
    expect(container.contains('第2话/2.png'), isTrue);
    expect(container.contains('第2话/2.PNG'), isFalse);
    expect(await container.readBytes('第2话/2.png'), generatedMangaPng());
    await expectLater(
      container.readBytes('missing.png'),
      _throwsCode('manga_resource_missing'),
    );
  });

  test('decodes strictly round-tripped legacy Chinese ZIP names', () async {
    final encoded = await _encodedArchive([
      ArchiveFile.bytes('chapte/1.png', generatedMangaPng()),
    ]);
    final legacyName = [
      0xb5,
      0xda,
      0x30,
      0x31,
      0xbb,
      0xd8,
      0x2f,
      0x31,
      0x2e,
      0x70,
      0x6e,
      0x67,
    ];
    final source = await _writeBytes(
      temporaryDirectory,
      _replaceFirstFilename(encoded, legacyName),
    );
    final container = await DartIoMangaArchiveContainer.open(
      source.path,
      legacyFilenameDecoder: (bytes) async =>
          bytes.length == legacyName.length ? '第01回/1.png' : null,
    );
    addTearDown(container.close);

    expect(container.contains('第01回/1.png'), isTrue);
    expect(await container.readBytes('第01回/1.png'), generatedMangaPng());
  });

  test('closed container cannot be reused', () async {
    final source = await _writeBytes(temporaryDirectory, basicMangaArchive());
    final container = await DartIoMangaArchiveContainer.open(source.path);

    await container.close();

    expect(() => container.contains('第2话/2.png'), throwsStateError);
  });

  group('unsafe paths', () {
    for (final path in [
      '../secret.png',
      'chapter/../secret.png',
      '/absolute.png',
      r'C:\secret.png',
      r'chapter\1.png',
      'chapter//1.png',
      'chapter/./1.png',
      'chapter/%2e%2e/secret.png',
      'chapter/1.png\u0000',
      '%broken',
    ]) {
      test('rejects $path', () {
        expect(
          () => normalizeMangaArchivePath(path),
          _throwsCode('manga_unsafe_path'),
        );
      });
    }

    test('URI decoding cannot create duplicate paths', () async {
      final source = await _writeArchive(temporaryDirectory, [
        ArchiveFile.bytes('chapter/1.png', generatedMangaPng()),
        ArchiveFile.bytes('chapter%2F1.png', generatedMangaPng()),
      ]);

      await expectLater(
        DartIoMangaArchiveContainer.open(source.path),
        _throwsCode('manga_unsafe_path'),
      );
    });

    test('implicit file-directory conflicts are rejected', () async {
      final source = await _writeArchive(temporaryDirectory, [
        ArchiveFile.string('chapter', 'file'),
        ArchiveFile.bytes('chapter/1.png', generatedMangaPng()),
      ]);

      await expectLater(
        DartIoMangaArchiveContainer.open(source.path),
        _throwsCode('manga_unsafe_path'),
      );
    });
  });

  test('encrypted ZIP flag is rejected before page reads', () async {
    final encoded = await _encodedArchive([
      ArchiveFile.bytes('chapter/1.png', generatedMangaPng()),
    ]);
    final source = await _writeBytes(
      temporaryDirectory,
      _markZipEncrypted(encoded),
    );

    await expectLater(
      DartIoMangaArchiveContainer.open(source.path),
      _throwsCode('manga_encrypted_archive'),
    );
  });

  test('archive byte-size budget is enforced before decoding', () async {
    final source = await _writeBytes(temporaryDirectory, basicMangaArchive());

    await expectLater(
      DartIoMangaArchiveContainer.open(
        source.path,
        budget: const MangaArchiveBudget(maximumArchiveSize: 4),
      ),
      _throwsCode('manga_resource_limit'),
    );
  });

  test('entry count and single-entry budgets are enforced', () async {
    final source = await _writeArchive(temporaryDirectory, [
      ArchiveFile.string('one.png', '12345'),
      ArchiveFile.string('two.png', '1'),
    ]);

    await expectLater(
      DartIoMangaArchiveContainer.open(
        source.path,
        budget: const MangaArchiveBudget(maximumEntryCount: 1),
      ),
      _throwsCode('manga_resource_limit'),
    );
    await expectLater(
      DartIoMangaArchiveContainer.open(
        source.path,
        budget: const MangaArchiveBudget(maximumEntrySize: 4),
      ),
      _throwsCode('manga_resource_limit'),
    );
  });

  test(
    'total expanded size and compression ratio budgets are enforced',
    () async {
      final totalSource = await _writeArchive(temporaryDirectory, [
        ArchiveFile.string('one.png', '123'),
        ArchiveFile.string('two.png', '456'),
      ]);
      final compressedSource = await _writeArchive(temporaryDirectory, [
        ArchiveFile.string('compressed.png', 'a' * 10000),
      ]);

      await expectLater(
        DartIoMangaArchiveContainer.open(
          totalSource.path,
          budget: const MangaArchiveBudget(maximumTotalSize: 5),
        ),
        _throwsCode('manga_resource_limit'),
      );
      await expectLater(
        DartIoMangaArchiveContainer.open(
          compressedSource.path,
          budget: const MangaArchiveBudget(maximumCompressionRatio: 2),
        ),
        _throwsCode('manga_resource_limit'),
      );
    },
  );

  test('damaged ZIP maps to a stable container failure', () async {
    final source = await _writeBytes(temporaryDirectory, [1, 2, 3, 4]);

    await expectLater(
      DartIoMangaArchiveContainer.open(source.path),
      _throwsCode('manga_invalid_container'),
    );
  });

  test('CRC mismatch is rejected during the requested page read', () async {
    final encoded = await _encodedArchive([
      ArchiveFile.noCompress('chapter/1.png', 4, [1, 2, 3, 4]),
    ]);
    final source = await _writeBytes(
      temporaryDirectory,
      _corruptFirstStoredEntry(encoded),
    );
    final container = await DartIoMangaArchiveContainer.open(source.path);
    addTearDown(container.close);

    await expectLater(
      container.readBytes('chapter/1.png'),
      _throwsCode('manga_invalid_container'),
    );
  });
}

Future<File> _writeArchive(
  Directory directory,
  List<ArchiveFile> entries,
) async {
  return _writeBytes(directory, await _encodedArchive(entries));
}

Future<List<int>> _encodedArchive(List<ArchiveFile> entries) async {
  final archive = Archive();
  for (final entry in entries) {
    archive.add(entry);
  }
  return ZipEncoder().encodeBytes(archive);
}

List<int> _markZipEncrypted(List<int> original) {
  final bytes = List<int>.from(original);
  for (var index = 0; index <= bytes.length - 4; index++) {
    final isLocal =
        bytes[index] == 0x50 &&
        bytes[index + 1] == 0x4b &&
        bytes[index + 2] == 0x03 &&
        bytes[index + 3] == 0x04;
    final isCentral =
        bytes[index] == 0x50 &&
        bytes[index + 1] == 0x4b &&
        bytes[index + 2] == 0x01 &&
        bytes[index + 3] == 0x02;
    if (isLocal) {
      bytes[index + 6] |= 0x1;
    } else if (isCentral) {
      bytes[index + 8] |= 0x1;
    }
  }
  return bytes;
}

List<int> _replaceFirstFilename(List<int> original, List<int> replacement) {
  final bytes = List<int>.from(original);
  final originalLength = bytes[26] | (bytes[27] << 8);
  if (originalLength != replacement.length) {
    throw ArgumentError('replacement must keep the original byte length');
  }
  bytes.setRange(30, 30 + replacement.length, replacement);
  for (var index = 0; index <= bytes.length - 4; index++) {
    if (bytes[index] == 0x50 &&
        bytes[index + 1] == 0x4b &&
        bytes[index + 2] == 0x01 &&
        bytes[index + 3] == 0x02) {
      final nameLength = bytes[index + 28] | (bytes[index + 29] << 8);
      if (nameLength != replacement.length) {
        throw ArgumentError('central filename length changed');
      }
      bytes.setRange(index + 46, index + 46 + replacement.length, replacement);
      bytes[index + 8] &= ~0x8;
      bytes[index + 9] &= ~0x8;
      break;
    }
  }
  bytes[6] &= ~0x8;
  bytes[7] &= ~0x8;
  return bytes;
}

List<int> _corruptFirstStoredEntry(List<int> original) {
  final bytes = List<int>.from(original);
  final nameLength = bytes[26] | (bytes[27] << 8);
  final extraLength = bytes[28] | (bytes[29] << 8);
  final dataOffset = 30 + nameLength + extraLength;
  bytes[dataOffset] ^= 0xff;
  return bytes;
}

Future<File> _writeBytes(Directory directory, List<int> bytes) async {
  final file = File(
    '${directory.path}${Platform.pathSeparator}'
    '${DateTime.now().microsecondsSinceEpoch}.cbz',
  );
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

Matcher _throwsCode(String code) =>
    throwsA(isA<AppFailure>().having((failure) => failure.code, 'code', code));
