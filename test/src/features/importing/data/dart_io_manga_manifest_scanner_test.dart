import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/importing/data/dart_io_manga_manifest_scanner.dart';
import 'package:mirascope/src/features/importing/data/flutter_manga_image_decoder.dart';
import 'package:mirascope/src/features/importing/domain/manga_source.dart';

import '../../../../support/manga_test_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'mirascope-manga-manifest-',
    );
  });
  tearDown(() => temporaryDirectory.delete(recursive: true));

  const scanner = DartIoMangaManifestScanner(FlutterMangaImageDecoder());

  test(
    'scans and freezes a CBZ manifest while skipping its corrupt page',
    () async {
      final archive = File(
        '${temporaryDirectory.path}${Platform.pathSeparator}book.cbz',
      );
      await archive.writeAsBytes(basicMangaArchive());

      final manifest = await scanner.scan(
        MangaSourceSelection(path: archive.path, kind: MangaSourceKind.archive),
      );

      expect(manifest.chapters.map((chapter) => chapter.title), [
        '第2话',
        '第10话',
      ]);
      expect(manifest.chapters.first.pages.map((page) => page.sourcePath), [
        '第2话/2.png',
        '第2话/10.png',
      ]);
      expect(manifest.invalidImageCount, 1);
      expect(manifest.ignoredFileCount, 2);
    },
  );

  test('scans a directory with the same natural ordering rules', () async {
    final chapter = Directory(
      '${temporaryDirectory.path}${Platform.pathSeparator}第2话',
    );
    await chapter.create();
    await File(
      '${chapter.path}${Platform.pathSeparator}10.png',
    ).writeAsBytes(generatedMangaPng());
    await File(
      '${chapter.path}${Platform.pathSeparator}2.png',
    ).writeAsBytes(generatedMangaPng());
    await File(
      '${chapter.path}${Platform.pathSeparator}note.txt',
    ).writeAsString('ignored');

    final manifest = await scanner.scan(
      MangaSourceSelection(
        path: temporaryDirectory.path,
        kind: MangaSourceKind.directory,
      ),
    );

    expect(manifest.chapters.single.pages.map((page) => page.sourcePath), [
      '第2话/2.png',
      '第2话/10.png',
    ]);
    expect(manifest.ignoredFileCount, 1);
  });
}
