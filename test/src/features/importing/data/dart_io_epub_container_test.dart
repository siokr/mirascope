import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/data/dart_io_epub_container.dart';
import 'package:mirascope/src/features/importing/domain/epub_container.dart';

import '../../../../support/epub_test_fixture.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'mirascope-epub-container-',
    );
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  test('opens a valid EPUB and reads exact-case resources', () async {
    final source = await _writeBytes(
      temporaryDirectory,
      buildTestEpub(TestEpubVersion.epub3),
    );
    final container = await DartIoEpubContainer.open(source.path);
    addTearDown(container.close);

    expect(container.entries, isNotEmpty);
    expect(container.contains('META-INF/container.xml'), isTrue);
    expect(container.contains('meta-inf/container.xml'), isFalse);
    expect(
      utf8.decode(await container.readBytes('mimetype')),
      'application/epub+zip',
    );
    await expectLater(
      container.readBytes('missing.xhtml'),
      throwsCode('epub_resource_missing'),
    );
  });

  test('closed container cannot be reused', () async {
    final source = await _writeBytes(
      temporaryDirectory,
      buildTestEpub(TestEpubVersion.epub2),
    );
    final container = await DartIoEpubContainer.open(source.path);

    await container.close();

    expect(() => container.contains('mimetype'), throwsStateError);
  });

  group('unsafe paths', () {
    for (final path in <String>[
      '../secret',
      'OEBPS/../secret',
      '/absolute',
      r'C:\secret',
      r'OEBPS\chapter.xhtml',
      'OEBPS//chapter.xhtml',
      'OEBPS/./chapter.xhtml',
      'OEBPS/%2e%2e/secret',
      'OEBPS/chapter.xhtml\u0000',
      '%broken',
    ]) {
      test('rejects $path', () {
        expect(
          () => normalizeEpubContainerPath(path),
          throwsCode('epub_unsafe_path'),
        );
      });
    }

    test('URI decoding cannot create duplicate normalized entries', () async {
      final source = await _writeArchive(temporaryDirectory, <ArchiveFile>[
        ArchiveFile.string('OEBPS/chapter.xhtml', 'first'),
        ArchiveFile.string('OEBPS%2Fchapter.xhtml', 'second'),
      ]);

      await expectLater(
        DartIoEpubContainer.open(source.path),
        throwsCode('epub_unsafe_path'),
      );
    });

    test('directory and file cannot share one normalized path', () async {
      final source = await _writeArchive(temporaryDirectory, <ArchiveFile>[
        ArchiveFile.directory('OEBPS/'),
        ArchiveFile.string('OEBPS', 'collision'),
      ]);

      await expectLater(
        DartIoEpubContainer.open(source.path),
        throwsCode('epub_unsafe_path'),
      );
    });

    test('resource lookup preserves unsafe-path failure', () async {
      final source = await _writeBytes(
        temporaryDirectory,
        buildTestEpub(TestEpubVersion.epub3),
      );
      final container = await DartIoEpubContainer.open(source.path);
      addTearDown(container.close);

      expect(
        () => container.contains('../secret'),
        throwsCode('epub_unsafe_path'),
      );
      await expectLater(
        container.readBytes('../secret'),
        throwsCode('epub_unsafe_path'),
      );
    });
  });

  test('entry count budget is enforced before content reads', () async {
    final source = await _writeArchive(temporaryDirectory, <ArchiveFile>[
      ArchiveFile.string('one', '1'),
      ArchiveFile.string('two', '2'),
    ]);

    await expectLater(
      DartIoEpubContainer.open(
        source.path,
        budget: const EpubContainerBudget(maximumEntryCount: 1),
      ),
      throwsCode('epub_resource_limit'),
    );
  });

  test('single entry expanded-size budget is enforced', () async {
    final source = await _writeArchive(temporaryDirectory, <ArchiveFile>[
      ArchiveFile.string('large', '12345'),
    ]);

    await expectLater(
      DartIoEpubContainer.open(
        source.path,
        budget: const EpubContainerBudget(maximumEntrySize: 4),
      ),
      throwsCode('epub_resource_limit'),
    );
  });

  test('total expanded-size budget is enforced', () async {
    final source = await _writeArchive(temporaryDirectory, <ArchiveFile>[
      ArchiveFile.string('one', '123'),
      ArchiveFile.string('two', '456'),
    ]);

    await expectLater(
      DartIoEpubContainer.open(
        source.path,
        budget: const EpubContainerBudget(maximumTotalSize: 5),
      ),
      throwsCode('epub_resource_limit'),
    );
  });

  test('compression-ratio budget is enforced', () async {
    final source = await _writeArchive(temporaryDirectory, <ArchiveFile>[
      ArchiveFile.string('compressed', 'a' * 10000),
    ]);

    await expectLater(
      DartIoEpubContainer.open(
        source.path,
        budget: const EpubContainerBudget(maximumCompressionRatio: 2),
      ),
      throwsCode('epub_resource_limit'),
    );
  });

  test('invalid ZIP maps to a stable container failure', () async {
    final source = await _writeBytes(temporaryDirectory, <int>[1, 2, 3, 4]);

    await expectLater(
      DartIoEpubContainer.open(source.path),
      throwsCode('epub_invalid_container'),
    );
  });

  test('resolves safe relative references without escaping the root', () async {
    final source = await _writeBytes(
      temporaryDirectory,
      buildTestEpub(TestEpubVersion.epub3),
    );
    final container = await DartIoEpubContainer.open(source.path);
    addTearDown(container.close);

    expect(
      container.resolvePath(
        'OEBPS/package/content.opf',
        '../Text/chapter.xhtml',
      ),
      'OEBPS/Text/chapter.xhtml',
    );
    expect(
      () => container.resolvePath('content.opf', '../secret'),
      throwsCode('epub_unsafe_path'),
    );
    expect(
      () => container.resolvePath('content.opf', 'https://example.com/book'),
      throwsCode('epub_unsafe_path'),
    );
  });
}

Future<File> _writeArchive(
  Directory directory,
  List<ArchiveFile> entries,
) async {
  final archive = Archive();
  for (final entry in entries) {
    archive.add(entry);
  }
  return _writeBytes(directory, ZipEncoder().encodeBytes(archive));
}

Future<File> _writeBytes(Directory directory, List<int> bytes) async {
  final file = File(
    '${directory.path}${Platform.pathSeparator}'
    '${DateTime.now().microsecondsSinceEpoch}.epub',
  );
  await file.writeAsBytes(bytes);
  return file;
}

Matcher throwsCode(String code) =>
    throwsA(isA<AppFailure>().having((failure) => failure.code, 'code', code));
