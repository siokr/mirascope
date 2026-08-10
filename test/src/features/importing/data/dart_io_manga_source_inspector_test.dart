import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/data/dart_io_manga_source_inspector.dart';
import 'package:mirascope/src/features/importing/domain/manga_source.dart';

import '../../../../support/manga_test_fixture.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'mirascope-manga-source-',
    );
  });

  tearDown(() => temporaryDirectory.delete(recursive: true));

  test('ZIP and CBZ archives produce stable streaming fingerprints', () async {
    final bytes = basicMangaArchive();
    final zip = await _writeFile(temporaryDirectory, 'comic.ZIP', bytes);
    final cbz = await _writeFile(temporaryDirectory, 'comic.CBZ', bytes);
    const inspector = DartIoMangaSourceInspector();

    final zipCandidate = await inspector.inspect(
      MangaSourceSelection(path: zip.path, kind: MangaSourceKind.archive),
    );
    final cbzCandidate = await inspector.inspect(
      MangaSourceSelection(path: cbz.path, kind: MangaSourceKind.archive),
    );

    expect(zipCandidate.kind, MangaSourceKind.archive);
    expect(zipCandidate.fingerprint, cbzCandidate.fingerprint);
    expect(zipCandidate.fileSize, bytes.length);
    expect(zipCandidate.modifiedAt.isUtc, isTrue);
  });

  test('archive extension and ZIP signature are both required', () async {
    final wrongExtension = await _writeFile(
      temporaryDirectory,
      'comic.rar',
      basicMangaArchive(),
    );
    final wrongSignature = await _writeFile(temporaryDirectory, 'comic.cbz', [
      1,
      2,
      3,
      4,
    ]);
    const inspector = DartIoMangaSourceInspector();

    await expectLater(
      inspector.inspect(
        MangaSourceSelection(
          path: wrongExtension.path,
          kind: MangaSourceKind.archive,
        ),
      ),
      _throwsCode('manga_invalid_source'),
    );
    await expectLater(
      inspector.inspect(
        MangaSourceSelection(
          path: wrongSignature.path,
          kind: MangaSourceKind.archive,
        ),
      ),
      _throwsCode('manga_invalid_source'),
    );
  });

  test(
    'directory fingerprint is independent of the selected root path',
    () async {
      final first = await _createMangaDirectory(temporaryDirectory, 'first');
      final second = await _createMangaDirectory(temporaryDirectory, 'second');
      const inspector = DartIoMangaSourceInspector();

      final firstCandidate = await inspector.inspect(
        MangaSourceSelection(path: first.path, kind: MangaSourceKind.directory),
      );
      final secondCandidate = await inspector.inspect(
        MangaSourceSelection(
          path: second.path,
          kind: MangaSourceKind.directory,
        ),
      );

      expect(firstCandidate.fingerprint, secondCandidate.fingerprint);
      expect(firstCandidate.imageCount, 3);
      expect(firstCandidate.fileSize, generatedMangaPng().length * 3);
    },
  );

  test('directory identity ignores hidden and unsupported files', () async {
    final directory = await _createMangaDirectory(temporaryDirectory, 'comic');
    const inspector = DartIoMangaSourceInspector();
    final before = await inspector.inspect(
      MangaSourceSelection(
        path: directory.path,
        kind: MangaSourceKind.directory,
      ),
    );
    await _writeFile(directory, 'notes.txt', [1, 2, 3]);
    final hidden = Directory(
      '${directory.path}${Platform.pathSeparator}.cache',
    );
    await hidden.create();
    await _writeFile(hidden, 'cover.png', generatedMangaPng());

    final after = await inspector.inspect(
      MangaSourceSelection(
        path: directory.path,
        kind: MangaSourceKind.directory,
      ),
    );

    expect(after.fingerprint, before.fingerprint);
    expect(after.imageCount, 3);
  });

  test('directory without supported images is rejected', () async {
    final directory = Directory(
      '${temporaryDirectory.path}${Platform.pathSeparator}empty-comic',
    );
    await directory.create();
    await _writeFile(directory, 'notes.txt', [1]);

    await expectLater(
      const DartIoMangaSourceInspector().inspect(
        MangaSourceSelection(
          path: directory.path,
          kind: MangaSourceKind.directory,
        ),
      ),
      _throwsCode('manga_no_images'),
    );
  });
}

Future<Directory> _createMangaDirectory(
  Directory temporaryDirectory,
  String name,
) async {
  final root = Directory(
    '${temporaryDirectory.path}${Platform.pathSeparator}$name',
  );
  final chapter = Directory('${root.path}${Platform.pathSeparator}chapter');
  await chapter.create(recursive: true);
  await _writeFile(chapter, '10.PNG', generatedMangaPng());
  await _writeFile(chapter, '2.jpg', generatedMangaPng());
  await _writeFile(root, 'cover.webp', generatedMangaPng());
  return root;
}

Future<File> _writeFile(Directory directory, String name, List<int> bytes) {
  return File(
    '${directory.path}${Platform.pathSeparator}$name',
  ).writeAsBytes(bytes, flush: true);
}

Matcher _throwsCode(String code) =>
    throwsA(isA<AppFailure>().having((failure) => failure.code, 'code', code));
