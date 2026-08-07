import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/features/novel/data/dart_io_novel_reader_repository.dart';
import 'package:mirascope/src/features/novel/domain/content_unit.dart'
    as domain;

import '../../../core/database/database_test_support.dart';

void main() {
  late Directory root;
  late AppDatabase database;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('mirascope-reader-');
    database = createTestDatabase();
  });

  tearDown(() async {
    await database.close();
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('strictly reads the body from a validated locator and hash', () async {
    const complete = '第1章 标题\n正文😀';
    final file = File(
      '${root.path}${Platform.pathSeparator}content'
      '${Platform.pathSeparator}media-1.txt',
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(utf8.encode(complete));
    final repository = DartIoNovelReaderRepository(database, root);
    final unit = _unit(
      locator: 'txt-v1:0:7:${complete.length}',
      hash: sha256.convert(utf8.encode(complete)).toString(),
    );

    final chapter = await repository.readChapter(unit);

    expect(chapter.text, '正文😀');
  });

  test('rejects traversal, invalid ranges and content hash mismatch', () async {
    final repository = DartIoNovelReaderRepository(database, root);
    final invalidUnits = [
      _unit(contentRef: '../private.txt'),
      _unit(locator: 'txt-v1:0:99:100'),
      _unit(hash: 'wrong-hash'),
    ];
    final file = File(
      '${root.path}${Platform.pathSeparator}content'
      '${Platform.pathSeparator}media-1.txt',
    );
    await file.parent.create(recursive: true);
    await file.writeAsString('正文');

    for (final unit in invalidUnits) {
      await expectLater(repository.readChapter(unit), throwsA(anything));
    }
  });

  test('reads validated EPUB semantic blocks and local image paths', () async {
    final payload = utf8.encode(
      jsonEncode({
        'schema': 'epub-derived-v1',
        'blocks': [
          {
            'kind': 'heading',
            'text': '第一章',
            'headingLevel': 1,
            'styleSpans': [
              {'start': 0, 'end': 2, 'bold': true, 'italic': false},
            ],
          },
          {
            'kind': 'image',
            'imageRef':
                'epub/media-1/images/'
                'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.png',
            'altText': '插图',
          },
          {'kind': 'paragraph', 'text': '正文'},
        ],
      }),
    );
    final epubRoot = Directory('${root.path}-epub');
    addTearDown(() async {
      if (await epubRoot.exists()) await epubRoot.delete(recursive: true);
    });
    final file = File(
      '${epubRoot.path}${Platform.pathSeparator}content'
      '${Platform.pathSeparator}media-1${Platform.pathSeparator}chapters'
      '${Platform.pathSeparator}00000.json',
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(payload);
    final repository = DartIoNovelReaderRepository(
      database,
      root,
      derivedEpubRoot: epubRoot,
    );

    final chapter = await repository.readChapter(
      _unit(
        contentRef: 'epub/media-1/chapters/00000.json',
        locator: 'epub-v1:chapter-1',
        hash: sha256.convert(payload).toString(),
      ),
    );

    expect(chapter.isSemantic, isTrue);
    expect(chapter.text, '第一章\n\n正文');
    expect(chapter.blocks, hasLength(3));
    expect(chapter.blocks.first.styleSpans.single.bold, isTrue);
    expect(chapter.blocks[1].imagePath, contains('media-1'));
  });

  test('rejects EPUB image refs belonging to another media item', () async {
    final payload = utf8.encode(
      jsonEncode({
        'schema': 'epub-derived-v1',
        'blocks': [
          {
            'kind': 'image',
            'imageRef':
                'epub/other/images/'
                'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.png',
          },
        ],
      }),
    );
    final file = File(
      '${root.path}${Platform.pathSeparator}content'
      '${Platform.pathSeparator}media-1${Platform.pathSeparator}chapters'
      '${Platform.pathSeparator}00000.json',
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(payload);
    final repository = DartIoNovelReaderRepository(
      database,
      root,
      derivedEpubRoot: root,
    );

    await expectLater(
      repository.readChapter(
        _unit(
          contentRef: 'epub/media-1/chapters/00000.json',
          locator: 'epub-v1:chapter-1',
          hash: sha256.convert(payload).toString(),
        ),
      ),
      throwsFormatException,
    );
  });
}

domain.ContentUnit _unit({
  String contentRef = 'content/media-1.txt',
  String locator = 'txt-v1:0:0:2',
  String hash = 'wrong-hash',
}) => domain.ContentUnit(
  id: 'unit-1',
  mediaItemId: 'media-1',
  unitType: domain.ContentUnitType.chapter,
  title: 'First',
  orderIndex: 0,
  contentRef: contentRef,
  sourceLocator: locator,
  contentHash: hash,
);
