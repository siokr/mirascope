import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/importing/domain/derived_manga_store.dart';
import 'package:mirascope/src/features/library/data/dart_io_custom_cover_store.dart';

void main() {
  test('copies an encoded cover into managed application storage', () async {
    final root = await Directory.systemTemp.createTemp('custom-cover-test-');
    addTearDown(() => root.delete(recursive: true));
    final source = File('${root.path}${Platform.pathSeparator}selected.jpg');
    await source.writeAsBytes([1, 2, 3]);
    final store = DartIoCustomCoverStore(
      Directory('${root.path}${Platform.pathSeparator}managed'),
      _Encoder(Uint8List.fromList([9, 8, 7])),
    );

    final coverRef = await store.replaceFromFile(
      mediaItemId: 'book-1',
      sourcePath: source.path,
    );
    await source.delete();

    expect(coverRef, 'custom/book-1/cover.png');
    final managed = await store.resolve(coverRef);
    expect(managed, isNotNull);
    expect(await managed!.readAsBytes(), [9, 8, 7]);
  });

  test('rejects unsafe media identifiers before writing', () async {
    final root = await Directory.systemTemp.createTemp('custom-cover-test-');
    addTearDown(() => root.delete(recursive: true));
    final source = File('${root.path}${Platform.pathSeparator}selected.jpg');
    await source.writeAsBytes([1]);
    final store = DartIoCustomCoverStore(
      Directory('${root.path}${Platform.pathSeparator}managed'),
      _Encoder(Uint8List.fromList([9])),
    );

    await expectLater(
      store.replaceFromFile(mediaItemId: '../escape', sourcePath: source.path),
      throwsArgumentError,
    );
  });
}

final class _Encoder implements MangaThumbnailEncoder {
  const _Encoder(this.output);
  final Uint8List output;

  @override
  Future<Uint8List> encode(Uint8List sourceBytes) async => output;
}
