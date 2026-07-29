import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/data/dart_io_txt_source_reader.dart';
import 'package:mirascope/src/features/importing/domain/txt_source_candidate.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'mirascope-source-reader-',
    );
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  test('reads bytes without modifying the source file', () async {
    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}novel.txt',
    );
    final original = <int>[0xef, 0xbb, 0xbf, 0x41];
    await file.writeAsBytes(original);
    final stat = await file.stat();
    final candidate = _candidate(file, stat);

    final bytes = await DartIoTxtSourceReader().read(candidate);

    expect(bytes, original);
    expect(await file.readAsBytes(), original);
    final after = await file.stat();
    expect(after.modified, stat.modified);
    expect(after.size, stat.size);
  });

  test('rejects a file changed after fingerprinting', () async {
    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}changed.txt',
    );
    await file.writeAsString('before');
    final candidate = _candidate(file, await file.stat());
    await file.writeAsString('after content is longer');

    await expectLater(
      DartIoTxtSourceReader().read(candidate),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.code,
          'code',
          'source_changed',
        ),
      ),
    );
  });

  test('rejects mutation that happens during the read', () async {
    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}during.txt',
    );
    await file.writeAsString('before');
    final candidate = _candidate(file, await file.stat());
    final reader = DartIoTxtSourceReader(
      readBytes: (path) async {
        final bytes = await File(path).readAsBytes();
        await File(path).writeAsString('changed during reading');
        return bytes;
      },
    );

    await expectLater(
      reader.read(candidate),
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

TxtSourceCandidate _candidate(File file, FileStat stat) {
  return TxtSourceCandidate(
    path: file.path,
    fileSize: stat.size,
    modifiedAt: stat.modified.toUtc(),
    fingerprint: 'sha256:test:${stat.size}',
  );
}
