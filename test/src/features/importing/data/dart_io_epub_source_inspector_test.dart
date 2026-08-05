import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/data/dart_io_epub_source_inspector.dart';

import '../../../../support/epub_test_fixture.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'mirascope-epub-inspector-',
    );
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  test('valid EPUB produces a stable SHA-256 and size fingerprint', () async {
    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}novel.EPUB',
    );
    await file.writeAsBytes(buildTestEpub(TestEpubVersion.epub3));

    final first = await DartIoEpubSourceInspector().inspect(file.path);
    final second = await DartIoEpubSourceInspector().inspect(file.path);

    expect(first.fileSize, greaterThan(0));
    expect(first.fingerprint, startsWith('sha256:'));
    expect(first.fingerprint, second.fingerprint);
    expect(first.modifiedAt.isUtc, isTrue);
  });

  test('wrong extension is rejected before reading bytes', () async {
    var readHeader = false;
    final inspector = DartIoEpubSourceInspector(
      readHeader: (_) async {
        readHeader = true;
        return <int>[0x50, 0x4b, 0x03, 0x04];
      },
    );

    await expectLater(
      inspector.inspect('${temporaryDirectory.path}/novel.zip'),
      throwsCode('epub_invalid_container'),
    );
    expect(readHeader, isFalse);
  });

  test('non-ZIP content with EPUB extension is rejected', () async {
    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}fake.epub',
    );
    await file.writeAsString('not a zip');

    await expectLater(
      DartIoEpubSourceInspector().inspect(file.path),
      throwsCode('epub_invalid_container'),
    );
  });

  test('missing path maps to file_not_found', () async {
    final path = '${temporaryDirectory.path}${Platform.pathSeparator}gone.epub';

    await expectLater(
      DartIoEpubSourceInspector().inspect(path),
      throwsCode('file_not_found'),
    );
  });

  test('empty EPUB maps to empty_file', () async {
    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}empty.epub',
    );
    await file.create();

    await expectLater(
      DartIoEpubSourceInspector().inspect(file.path),
      throwsCode('empty_file'),
    );
  });

  test(
    'file above configured budget is rejected before reading header',
    () async {
      final file = File(
        '${temporaryDirectory.path}${Platform.pathSeparator}large.epub',
      );
      await file.writeAsBytes(<int>[0x50, 0x4b, 0x03, 0x04, 0]);
      var readHeader = false;
      final inspector = DartIoEpubSourceInspector(
        maximumFileSize: 4,
        readHeader: (_) async {
          readHeader = true;
          return const <int>[];
        },
      );

      await expectLater(
        inspector.inspect(file.path),
        throwsCode('epub_resource_limit'),
      );
      expect(readHeader, isFalse);
    },
  );

  test('file mutation during hashing maps to source_changed', () async {
    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}changing.epub',
    );
    await file.writeAsBytes(buildTestEpub(TestEpubVersion.epub2));
    final inspector = DartIoEpubSourceInspector(
      openByteStream: (path) async* {
        yield await File(path).readAsBytes();
        await File(path).writeAsBytes(<int>[0x50, 0x4b, 0x03, 0x04, 0]);
      },
    );

    await expectLater(
      inspector.inspect(file.path),
      throwsCode('source_changed'),
    );
  });
}

Matcher throwsCode(String code) =>
    throwsA(isA<AppFailure>().having((failure) => failure.code, 'code', code));
