import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

const _fixtureModified = '2026-08-10T00:00:00Z';

/// A generated, redistributable 1 x 1 PNG used only by tests.
Uint8List generatedMangaPng() => base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
  'YAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

Uint8List basicMangaArchive() => _encode([
  ArchiveFile.bytes('第10话/10.png', generatedMangaPng()),
  ArchiveFile.bytes('第2话/10.png', generatedMangaPng()),
  ArchiveFile.bytes('第2话/2.png', generatedMangaPng()),
  ArchiveFile.bytes('第2话/损坏.png', Uint8List.fromList([0, 1, 2, 3])),
  ArchiveFile.string('.hidden/ignored.txt', 'not an image'),
  ArchiveFile.string('第3话/readme.txt', 'empty chapter'),
]);

Uint8List traversalMangaArchive() =>
    _encode([ArchiveFile.bytes('../outside.png', generatedMangaPng())]);

Uint8List collidingMangaArchive() => _encode([
  ArchiveFile.string('chapter', 'file'),
  ArchiveFile.bytes('chapter/1.png', generatedMangaPng()),
]);

Uint8List oversizedMangaArchive({int repeatedBytes = 1024 * 1024}) =>
    _encode([ArchiveFile.string('chapter/1.png', 'x' * repeatedBytes)]);

Uint8List _encode(List<ArchiveFile> files) {
  final archive = Archive();
  for (final file in files) {
    archive.add(file);
  }
  return Uint8List.fromList(
    ZipEncoder().encodeBytes(
      archive,
      modified: DateTime.parse(_fixtureModified),
    ),
  );
}
