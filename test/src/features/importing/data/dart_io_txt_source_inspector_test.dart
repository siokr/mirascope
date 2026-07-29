import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/data/dart_io_txt_source_inspector.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'mirascope-source-inspector-',
    );
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  test('missing path maps to file_not_found', () async {
    final inspector = DartIoTxtSourceInspector();
    final path = '${temporaryDirectory.path}${Platform.pathSeparator}gone.txt';

    await expectLater(
      inspector.inspect(path),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.code,
          'code',
          'file_not_found',
        ),
      ),
    );
  });

  test('empty file maps to empty_file', () async {
    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}empty.txt',
    );
    await file.create();

    await expectLater(
      DartIoTxtSourceInspector().inspect(file.path),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.code,
          'code',
          'empty_file',
        ),
      ),
    );
  });

  test('known bytes produce a stable SHA-256 and size fingerprint', () async {
    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}known.txt',
    );
    await file.writeAsBytes(<int>[97, 98, 99]);

    final candidate = await DartIoTxtSourceInspector().inspect(file.path);

    expect(candidate.fileSize, 3);
    expect(
      candidate.fingerprint,
      'sha256:ba7816bf8f01cfea414140de5dae2223'
      'b00361a396177a9cb410ff61f20015ad:3',
    );
    expect(candidate.modifiedAt.isUtc, isTrue);
  });

  test(
    'same file name with different bytes produces different fingerprints',
    () async {
      final firstDirectory = await Directory(
        '${temporaryDirectory.path}${Platform.pathSeparator}first',
      ).create();
      final secondDirectory = await Directory(
        '${temporaryDirectory.path}${Platform.pathSeparator}second',
      ).create();
      final first = File(
        '${firstDirectory.path}${Platform.pathSeparator}novel.txt',
      );
      final second = File(
        '${secondDirectory.path}${Platform.pathSeparator}novel.txt',
      );
      await first.writeAsString('first');
      await second.writeAsString('second');
      final inspector = DartIoTxtSourceInspector();

      final firstCandidate = await inspector.inspect(first.path);
      final secondCandidate = await inspector.inspect(second.path);

      expect(firstCandidate.fingerprint, isNot(secondCandidate.fingerprint));
    },
  );

  test('permission errors map without exposing their path', () {
    const privatePath = r'C:\Users\private\secret.txt';
    final failure = mapFileSystemFailure(
      const FileSystemException(
        'Access denied',
        privatePath,
        OSError('Access denied', 5),
      ),
    );

    expect(failure.code, 'file_permission_denied');
    expect(failure.toString(), isNot(contains(privatePath)));
    expect(failure.message, isNot(contains(privatePath)));
  });

  test('file mutation during hashing maps to source_changed', () async {
    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}changing.txt',
    );
    await file.writeAsString('before');
    final inspector = DartIoTxtSourceInspector(
      openByteStream: (path) async* {
        yield await File(path).readAsBytes();
        await File(path).writeAsString('content changed and grew');
      },
    );

    await expectLater(
      inspector.inspect(file.path),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.code,
          'code',
          'source_changed',
        ),
      ),
    );
  });
}
