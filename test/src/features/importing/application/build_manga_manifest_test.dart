import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/application/build_manga_manifest.dart';
import 'package:mirascope/src/features/importing/application/natural_path_comparator.dart';
import 'package:mirascope/src/features/importing/domain/manga_manifest.dart';
import 'package:mirascope/src/features/manga/domain/manga_page.dart';

void main() {
  group('compareNaturalPaths', () {
    test('sorts numeric segments naturally with a deterministic tie break', () {
      final values = ['10.png', '02.png', '2.png', '1.png', '第10话', '第2话']
        ..sort(compareNaturalPaths);
      expect(values, ['1.png', '2.png', '02.png', '10.png', '第2话', '第10话']);
    });
  });

  group('BuildMangaManifest', () {
    const decoder = _FakeDecoder();

    test('freezes natural chapter and page order', () async {
      final manifest = await const BuildMangaManifest(decoder)([
        _image('第10话/10.png', 10),
        _image('第2话/10.png', 210),
        _image('第2话/2.png', 22),
        _image('第2话/1.png', 21),
      ]);

      expect(manifest.chapters.map((chapter) => chapter.title), [
        '第2话',
        '第10话',
      ]);
      expect(manifest.chapters.first.pages.map((page) => page.sourcePath), [
        '第2话/1.png',
        '第2话/2.png',
        '第2话/10.png',
      ]);
      expect(manifest.pageCount, 4);
      expect(manifest.chapters.first.pages.first.pixelWidth, 1);
      expect(
        manifest.chapters.first.pages.first.contentHash,
        startsWith('sha256:'),
      );
    });

    test('groups root images into the body chapter', () async {
      final manifest = await const BuildMangaManifest(decoder)([
        _image('2.jpg', 2),
        _image('1.jpg', 1),
      ]);
      expect(manifest.chapters.single.title, '正文');
      expect(manifest.chapters.single.pages.map((page) => page.sourcePath), [
        '1.jpg',
        '2.jpg',
      ]);
    });

    test('ignores hidden and unsupported files', () async {
      final manifest = await const BuildMangaManifest(decoder)([
        _image('.hidden/1.png', 1),
        _image('chapter/readme.txt', 2),
        _image('chapter/1.PNG', 3),
      ]);
      expect(manifest.pageCount, 1);
      expect(manifest.ignoredFileCount, 2);
    });

    test('drops corrupt images and empty chapters', () async {
      final manifest = await const BuildMangaManifest(decoder)([
        _image('空章节/bad.png', 0),
        _image('可读/1.png', 1),
      ]);
      expect(manifest.chapters.map((chapter) => chapter.title), ['可读']);
      expect(manifest.invalidImageCount, 1);
    });

    test('rejects a source with no decodable image', () async {
      await expectLater(
        const BuildMangaManifest(decoder)([
          _image('bad.png', 0),
          _image('readme.txt', 1),
        ]),
        throwsA(isA<AppFailure>()),
      );
    });
  });
}

MangaSourceImage _image(String path, int marker) => MangaSourceImage(
  path: path,
  readBytes: () async => Uint8List.fromList([marker]),
);

final class _FakeDecoder implements MangaImageDecoder {
  const _FakeDecoder();

  @override
  Future<MangaImageMetadata> decode(Uint8List bytes) async {
    if (bytes.single == 0) throw const FormatException('corrupt');
    return const MangaImageMetadata(
      type: MangaImageType.png,
      width: 1,
      height: 1,
    );
  }
}
