import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'manga_test_fixture.dart';

void main() {
  test('basic manga fixture exposes sorting and damaged-page cases', () {
    final archive = ZipDecoder().decodeBytes(basicMangaArchive());

    expect(
      archive.files.map((file) => file.name),
      containsAll([
        '第10话/10.png',
        '第2话/10.png',
        '第2话/2.png',
        '第2话/损坏.png',
        '.hidden/ignored.txt',
        '第3话/readme.txt',
      ]),
    );
  });

  test('security fixtures preserve hostile archive structures', () {
    final traversal = ZipDecoder().decodeBytes(traversalMangaArchive());
    final collision = ZipDecoder().decodeBytes(collidingMangaArchive());

    expect(traversal.files.single.name, '../outside.png');
    expect(
      collision.files.map((file) => file.name),
      containsAll(['chapter', 'chapter/1.png']),
    );
  });

  test('oversized fixture has a configurable expanded size', () {
    final archive = ZipDecoder().decodeBytes(
      oversizedMangaArchive(repeatedBytes: 4096),
    );

    expect(archive.files.single.size, 4096);
  });
}
