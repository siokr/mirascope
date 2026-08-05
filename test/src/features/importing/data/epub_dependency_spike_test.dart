import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:xml/xml.dart';

import '../../../../support/epub_test_fixture.dart';

void main() {
  for (final version in TestEpubVersion.values) {
    test('${version.name} fixture exercises archive, XML, and HTML', () {
      final bytes = buildTestEpub(version);
      final archive = ZipDecoder().decodeBytes(bytes);
      final files = <String, ArchiveFile>{
        for (final file in archive.files) file.name: file,
      };

      expect(files.keys.first, 'mimetype');
      expect(_text(files, 'mimetype'), 'application/epub+zip');

      final container = XmlDocument.parse(
        _text(files, 'META-INF/container.xml'),
      );
      final rootfile = container.findAllElements('rootfile').single;
      final packagePath = rootfile.getAttribute('full-path');
      expect(packagePath, 'OEBPS/content.opf');

      final package = XmlDocument.parse(_text(files, packagePath!));
      expect(package.findAllElements('itemref'), hasLength(1));
      final title = package.descendants.whereType<XmlElement>().singleWhere(
        (element) => element.name.local == 'title',
      );
      expect(title.innerText, contains('测试书'));

      final chapter = html_parser.parse(_text(files, 'OEBPS/chapter.xhtml'));
      expect(chapter.querySelector('h1')?.text, '第一章');
      expect(chapter.querySelector('p')?.text, contains('mirascope'));

      final navigationPath = version == TestEpubVersion.epub2
          ? 'OEBPS/toc.ncx'
          : 'OEBPS/nav.xhtml';
      expect(files, contains(navigationPath));
    });
  }
}

String _text(Map<String, ArchiveFile> files, String path) {
  final bytes = files[path]?.readBytes();
  if (bytes == null) {
    throw StateError('Missing fixture entry: $path');
  }
  return utf8.decode(bytes);
}
