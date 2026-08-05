import 'dart:typed_data';

import 'package:archive/archive.dart';

enum TestEpubVersion { epub2, epub3 }

/// Builds a deterministic, self-authored EPUB fixture for parser tests.
Uint8List buildTestEpub(TestEpubVersion version) {
  final archive = Archive();
  final mimetype = ArchiveFile.string('mimetype', 'application/epub+zip')
    ..compression = CompressionType.none;
  archive.add(mimetype);
  archive.add(
    ArchiveFile.string(
      'META-INF/container.xml',
      _containerXml,
    ),
  );

  switch (version) {
    case TestEpubVersion.epub2:
      archive
        ..add(ArchiveFile.string('OEBPS/content.opf', _epub2Package))
        ..add(ArchiveFile.string('OEBPS/toc.ncx', _epub2Ncx))
        ..add(ArchiveFile.string('OEBPS/chapter.xhtml', _chapter));
    case TestEpubVersion.epub3:
      archive
        ..add(ArchiveFile.string('OEBPS/content.opf', _epub3Package))
        ..add(ArchiveFile.string('OEBPS/nav.xhtml', _epub3Navigation))
        ..add(ArchiveFile.string('OEBPS/chapter.xhtml', _chapter));
  }

  return ZipEncoder().encodeBytes(
    archive,
    modified: DateTime.utc(2026, 8, 5),
  );
}

const _containerXml = '''<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>''';

const _epub2Package = '''<?xml version="1.0" encoding="UTF-8"?>
<package version="2.0" unique-identifier="book-id" xmlns="http://www.idpf.org/2007/opf">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="book-id">urn:uuid:mirascope-epub2</dc:identifier>
    <dc:title>Mirascope EPUB 2 测试书</dc:title>
    <dc:language>zh-CN</dc:language>
  </metadata>
  <manifest>
    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
    <item id="chapter" href="chapter.xhtml" media-type="application/xhtml+xml"/>
  </manifest>
  <spine toc="ncx"><itemref idref="chapter"/></spine>
</package>''';

const _epub2Ncx = '''<?xml version="1.0" encoding="UTF-8"?>
<ncx version="2005-1" xmlns="http://www.daisy.org/z3986/2005/ncx/">
  <navMap><navPoint id="chapter"><navLabel><text>第一章</text></navLabel><content src="chapter.xhtml#start"/></navPoint></navMap>
</ncx>''';

const _epub3Package = '''<?xml version="1.0" encoding="UTF-8"?>
<package version="3.0" unique-identifier="book-id" xmlns="http://www.idpf.org/2007/opf">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="book-id">urn:uuid:mirascope-epub3</dc:identifier>
    <dc:title>Mirascope EPUB 3 测试书</dc:title>
    <dc:language>zh-CN</dc:language>
  </metadata>
  <manifest>
    <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
    <item id="chapter" href="chapter.xhtml" media-type="application/xhtml+xml"/>
  </manifest>
  <spine><itemref idref="chapter"/></spine>
</package>''';

const _epub3Navigation = '''<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
  <head><title>目录</title></head>
  <body><nav epub:type="toc"><ol><li><a href="chapter.xhtml#start">第一章</a></li></ol></nav></body>
</html>''';

const _chapter = '''<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="zh-CN">
  <head><title>第一章</title></head>
  <body><h1 id="start">第一章</h1><p>这是由 mirascope 项目生成的测试正文。</p></body>
</html>''';
