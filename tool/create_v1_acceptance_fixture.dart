import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';

import '../test/generated_migrations/schema_v1.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    stderr.writeln(
      'Usage: dart run tool/create_v1_acceptance_fixture.dart <output-dir>',
    );
    exitCode = 64;
    return;
  }

  final output = Directory(arguments.single).absolute;
  if (await output.exists()) {
    stderr.writeln('Refusing to overwrite existing directory: ${output.path}');
    exitCode = 73;
    return;
  }

  final contentDirectory = Directory(
    '${output.path}${Platform.pathSeparator}derived_txt'
    '${Platform.pathSeparator}content',
  );
  await contentDirectory.create(recursive: true);

  const text =
      '第一章 合成迁移验收\n\n这是由仓库工具生成的 schema v1 测试内容。\n'
      '候选应用成功显示并打开本书，表示 v1 数据已升级且派生正文仍可读取。\n';
  const mediaId = 'v1-acceptance-media';
  const chapterId = 'v1-acceptance-chapter';
  const timestamp = 1785715200000;
  final contentHash = sha256.convert(utf8.encode(text)).toString();
  final contentFile = File(
    '${contentDirectory.path}${Platform.pathSeparator}$mediaId.txt',
  );
  await contentFile.writeAsBytes(utf8.encode(text), flush: true);

  final databaseFile = File(
    '${output.path}${Platform.pathSeparator}mirascope.sqlite',
  );
  final database = DatabaseAtV1(NativeDatabase(databaseFile));
  try {
    if (!await File('drift_schemas/drift_schema_v1.json').exists()) {
      throw StateError('Run this tool from the repository root.');
    }
    await database.customSelect('SELECT 1').getSingle();
    final schemaVersion = await database
        .customSelect('PRAGMA user_version')
        .map((row) => row.read<int>('user_version'))
        .getSingle();
    if (schemaVersion != 1) {
      throw StateError('Expected schema v1, got v$schemaVersion.');
    }
    await database.customStatement(
      'INSERT INTO media_items '
      '(id, media_type, title, created_at, updated_at) '
      'VALUES (?, ?, ?, ?, ?)',
      [mediaId, 'novel', 'schema v1 迁移验收', timestamp, timestamp],
    );
    await database.customStatement(
      'INSERT INTO library_entries '
      '(id, media_item_id, favorite, added_at, last_opened_at, archived_at) '
      'VALUES (?, ?, ?, ?, ?, NULL)',
      ['v1-acceptance-library', mediaId, 0, timestamp, timestamp],
    );
    await database.customStatement(
      'INSERT INTO content_units '
      '(id, media_item_id, unit_type, title, order_index, content_ref, '
      'source_locator, content_hash) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        chapterId,
        mediaId,
        'chapter',
        '第一章 合成迁移验收',
        0,
        'content/$mediaId.txt',
        'txt-v1:0:0:${text.length}',
        contentHash,
      ],
    );
    await database.customStatement(
      'INSERT INTO reading_progress '
      '(id, media_item_id, content_unit_id, locator, fraction, updated_at, '
      'revision) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        'v1-acceptance-progress',
        mediaId,
        chapterId,
        'char-v1:0',
        0.0,
        timestamp,
        1,
      ],
    );
    await database.customStatement(
      'INSERT INTO import_records '
      '(id, media_item_id, source_path, source_kind, file_size, modified_at, '
      'fingerprint, status, error_code, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, NULL, ?)',
      [
        'v1-acceptance-import',
        mediaId,
        r'C:\fixture\v1-acceptance.txt',
        'txtFile',
        utf8.encode(text).length,
        timestamp,
        'v1-acceptance-fixture',
        'missing',
        timestamp,
      ],
    );
  } finally {
    await database.close();
  }

  stdout.writeln('Created schema v1 fixture at ${output.path}');
}
