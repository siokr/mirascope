import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/application/parse_epub_package.dart';
import 'package:mirascope/src/features/importing/data/dart_io_epub_container.dart';

import '../../../../support/epub_test_fixture.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'mirascope-epub-parser-',
    );
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  for (final version in TestEpubVersion.values) {
    test('parses ${version.name} metadata spine and navigation', () async {
      final path = await _writeBytes(
        temporaryDirectory,
        buildTestEpub(version),
      );
      final container = await DartIoEpubContainer.open(path);
      addTearDown(container.close);

      final book = await const ParseEpubPackage()(container);

      expect(book.version, version == TestEpubVersion.epub2 ? '2.0' : '3.0');
      expect(book.title, contains('测试书'));
      expect(book.packagePath, 'OEBPS/content.opf');
      expect(book.spine, hasLength(1));
      expect(book.spine.single.item.path, 'OEBPS/chapter.xhtml');
      expect(book.navigation.single.title, '第一章');
      expect(book.navigation.single.targetPath, 'OEBPS/chapter.xhtml');
      expect(book.navigation.single.fragment, 'start');
    });
  }

  test('missing container.xml has a stable failure', () async {
    final path = await _writeArchive(temporaryDirectory, <ArchiveFile>[
      ArchiveFile.string('mimetype', 'application/epub+zip'),
    ]);
    final container = await DartIoEpubContainer.open(path);
    addTearDown(container.close);

    await expectLater(
      const ParseEpubPackage()(container),
      throwsCode('epub_invalid_container'),
    );
  });

  test('missing OPF has a stable package failure', () async {
    final path = await _writeBook(
      temporaryDirectory,
      containerXml: _containerXml,
    );
    final container = await DartIoEpubContainer.open(path);
    addTearDown(container.close);

    await expectLater(
      const ParseEpubPackage()(container),
      throwsCode('epub_package_missing'),
    );
  });

  test('missing spine resource is rejected', () async {
    final path = await _writeBook(
      temporaryDirectory,
      containerXml: _containerXml,
      packageXml: _packageXml(
        manifest:
            '<item id="chapter" href="missing.xhtml" media-type="application/xhtml+xml"/>',
        spine: '<itemref idref="chapter"/>',
      ),
    );
    final container = await DartIoEpubContainer.open(path);
    addTearDown(container.close);

    await expectLater(
      const ParseEpubPackage()(container),
      throwsCode('epub_resource_missing'),
    );
  });

  test('empty spine is rejected', () async {
    final path = await _writeBook(
      temporaryDirectory,
      containerXml: _containerXml,
      packageXml: _packageXml(
        manifest:
            '<item id="chapter" href="chapter.xhtml" media-type="application/xhtml+xml"/>',
        spine: '',
      ),
      extras: <ArchiveFile>[
        ArchiveFile.string(
          'OEBPS/chapter.xhtml',
          '<html><body>text</body></html>',
        ),
      ],
    );
    final container = await DartIoEpubContainer.open(path);
    addTearDown(container.close);

    await expectLater(
      const ParseEpubPackage()(container),
      throwsCode('epub_spine_empty'),
    );
  });

  test('relative manifest paths resolve inside the container', () async {
    final path = await _writeBook(
      temporaryDirectory,
      containerXml: _containerXml.replaceAll(
        'OEBPS/content.opf',
        'OEBPS/Package/content.opf',
      ),
      packagePath: 'OEBPS/Package/content.opf',
      packageXml: _packageXml(
        manifest:
            '<item id="chapter" href="../Text/chapter.xhtml" media-type="application/xhtml+xml"/>',
        spine: '<itemref idref="chapter" linear="no"/>',
      ),
      extras: <ArchiveFile>[
        ArchiveFile.string(
          'OEBPS/Text/chapter.xhtml',
          '<html><body>text</body></html>',
        ),
      ],
    );
    final container = await DartIoEpubContainer.open(path);
    addTearDown(container.close);

    final book = await const ParseEpubPackage()(container);

    expect(book.spine.single.item.path, 'OEBPS/Text/chapter.xhtml');
    expect(book.spine.single.linear, isFalse);
    expect(book.navigation, isEmpty);
  });

  test('encrypted XHTML is rejected as unsupported DRM', () async {
    final path = await _writeBook(
      temporaryDirectory,
      containerXml: _containerXml,
      packageXml: _packageXml(
        manifest:
            '<item id="chapter" href="chapter.xhtml" media-type="application/xhtml+xml"/>',
        spine: '<itemref idref="chapter"/>',
      ),
      extras: <ArchiveFile>[
        ArchiveFile.string(
          'OEBPS/chapter.xhtml',
          '<html><body>encrypted</body></html>',
        ),
        ArchiveFile.string('META-INF/encryption.xml', _encryptionXml),
      ],
    );
    final container = await DartIoEpubContainer.open(path);
    addTearDown(container.close);

    await expectLater(
      const ParseEpubPackage()(container),
      throwsCode('epub_drm_unsupported'),
    );
  });

  test('spine item budget is enforced', () async {
    final path = await _writeBook(
      temporaryDirectory,
      containerXml: _containerXml,
      packageXml: _packageXml(
        manifest:
            '<item id="one" href="one.xhtml" media-type="application/xhtml+xml"/>'
            '<item id="two" href="two.xhtml" media-type="application/xhtml+xml"/>',
        spine: '<itemref idref="one"/><itemref idref="two"/>',
      ),
      extras: <ArchiveFile>[
        ArchiveFile.string('OEBPS/one.xhtml', '<html/>'),
        ArchiveFile.string('OEBPS/two.xhtml', '<html/>'),
      ],
    );
    final container = await DartIoEpubContainer.open(path);
    addTearDown(container.close);

    await expectLater(
      const ParseEpubPackage(maximumSpineItems: 1)(container),
      throwsCode('epub_resource_limit'),
    );
  });

  test('UTF-16 container and OPF documents are supported', () async {
    final archive = Archive()
      ..add(ArchiveFile.string('mimetype', 'application/epub+zip'))
      ..add(
        ArchiveFile.bytes('META-INF/container.xml', _utf16Le(_containerXml)),
      )
      ..add(
        ArchiveFile.bytes(
          'OEBPS/content.opf',
          _utf16Be(
            _packageXml(
              manifest:
                  '<item id="chapter" href="chapter.xhtml" media-type="application/xhtml+xml"/>',
              spine: '<itemref idref="chapter"/>',
            ),
          ),
        ),
      )
      ..add(ArchiveFile.string('OEBPS/chapter.xhtml', '<html/>'));
    final path = await _writeBytes(
      temporaryDirectory,
      ZipEncoder().encodeBytes(archive),
    );
    final container = await DartIoEpubContainer.open(path);
    addTearDown(container.close);

    final book = await const ParseEpubPackage()(container);

    expect(book.title, '测试书');
    expect(book.spine.single.item.path, 'OEBPS/chapter.xhtml');
  });
}

Future<String> _writeBook(
  Directory directory, {
  required String containerXml,
  String packagePath = 'OEBPS/content.opf',
  String? packageXml,
  List<ArchiveFile> extras = const <ArchiveFile>[],
}) {
  return _writeArchive(directory, <ArchiveFile>[
    ArchiveFile.string('mimetype', 'application/epub+zip'),
    ArchiveFile.string('META-INF/container.xml', containerXml),
    if (packageXml != null) ArchiveFile.string(packagePath, packageXml),
    ...extras,
  ]);
}

Future<String> _writeArchive(Directory directory, List<ArchiveFile> entries) {
  final archive = Archive();
  for (final entry in entries) {
    archive.add(entry);
  }
  return _writeBytes(directory, ZipEncoder().encodeBytes(archive));
}

Future<String> _writeBytes(Directory directory, List<int> bytes) async {
  final file = File(
    '${directory.path}${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}.epub',
  );
  await file.writeAsBytes(bytes);
  return file.path;
}

Matcher throwsCode(String code) =>
    throwsA(isA<AppFailure>().having((failure) => failure.code, 'code', code));

List<int> _utf16Le(String value) => <int>[
  0xff,
  0xfe,
  for (final unit in value.codeUnits) ...<int>[unit & 0xff, unit >> 8],
];

List<int> _utf16Be(String value) => <int>[
  0xfe,
  0xff,
  for (final unit in value.codeUnits) ...<int>[unit >> 8, unit & 0xff],
];

const _containerXml = '''<?xml version="1.0" encoding="UTF-8"?>
<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles>
</container>''';

String _packageXml({required String manifest, required String spine}) =>
    '''
<package version="3.0" xmlns="http://www.idpf.org/2007/opf">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:title>测试书</dc:title></metadata>
  <manifest>$manifest</manifest><spine>$spine</spine>
</package>''';

const _encryptionXml = '''
<encryption xmlns="urn:oasis:names:tc:opendocument:xmlns:container" xmlns:enc="http://www.w3.org/2001/04/xmlenc#">
  <enc:EncryptedData><enc:CipherData><enc:CipherReference URI="../OEBPS/chapter.xhtml"/></enc:CipherData></enc:EncryptedData>
</encryption>''';
