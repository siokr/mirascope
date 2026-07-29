import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/importing/data/dart_io_derived_txt_store.dart';

void main() {
  late Directory root;
  late DartIoDerivedTxtStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('mirascope-derived-');
    store = DartIoDerivedTxtStore(root);
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test(
    'stages UTF-8 then atomically promotes to a relative content ref',
    () async {
      final staged = await store.stage(mediaItemId: 'media-1', text: '正文😀');

      expect(staged.contentRef, 'content/media-1.txt');
      expect(
        await File(staged.temporaryToken).readAsBytes(),
        utf8.encode('正文😀'),
      );

      await store.promote(staged);

      expect(await File(staged.temporaryToken).exists(), isFalse);
      final committed = File(
        '${root.path}${Platform.pathSeparator}content'
        '${Platform.pathSeparator}media-1.txt',
      );
      expect(await committed.readAsString(), '正文😀');
      await store.removeCommitted(staged);
      expect(await committed.exists(), isFalse);
    },
  );

  test('discard is idempotent and unsafe IDs are rejected', () async {
    final staged = await store.stage(mediaItemId: 'safe_id', text: '正文');
    await store.discard(staged);
    await store.discard(staged);

    await expectLater(
      store.stage(mediaItemId: '../escape', text: '正文'),
      throwsArgumentError,
    );
  });
}
