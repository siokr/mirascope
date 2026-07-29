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
