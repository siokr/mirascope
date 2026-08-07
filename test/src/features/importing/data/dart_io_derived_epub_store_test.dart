import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/data/dart_io_derived_epub_store.dart';
import 'package:mirascope/src/features/importing/domain/epub_container.dart';
import 'package:mirascope/src/features/importing/domain/epub_semantic_content.dart';
import 'package:mirascope/src/features/importing/domain/parsed_epub.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('mirascope-epub-derived-');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('writes deterministic chapters and deduplicated images', () async {
    final store = DartIoDerivedEpubStore(root);
    final container = _Container({
      'OPS/image.png': Uint8List.fromList(<int>[1, 2, 3]),
    });
    final staged = await store.stage(
      mediaItemId: 'media-1',
      book: _book,
      chapters: [_chapter, _chapter],
      container: container,
    );

    expect(staged.chapters, hasLength(2));
    expect(
      staged.chapters.first.contentRef,
      'epub/media-1/chapters/00000.json',
    );
    expect(container.reads, ['OPS/image.png']);
    expect(
      Directory(
        '${staged.temporaryToken}${Platform.pathSeparator}images',
      ).listSync(),
      hasLength(1),
    );
    final chapter =
        jsonDecode(
              await File(
                '${staged.temporaryToken}${Platform.pathSeparator}chapters'
                '${Platform.pathSeparator}00000.json',
              ).readAsString(),
            )
            as Map<String, dynamic>;
    expect(chapter['schema'], 'epub-derived-v1');
    expect(
      (chapter['blocks'] as List<dynamic>).last['imageRef'],
      startsWith('epub/media-1/images/'),
    );

    await store.promote(staged);
    expect(Directory(staged.temporaryToken).existsSync(), isFalse);
    expect(
      File(
        '${root.path}${Platform.pathSeparator}content'
        '${Platform.pathSeparator}media-1${Platform.pathSeparator}'
        'manifest.json',
      ).existsSync(),
      isTrue,
    );
    await store.removeCommittedRef(staged.chapters.last.contentRef);
    expect(
      Directory(
        '${root.path}${Platform.pathSeparator}content'
        '${Platform.pathSeparator}media-1',
      ).existsSync(),
      isFalse,
    );
  });

  test('resource limit failure removes partial staging directory', () async {
    final store = DartIoDerivedEpubStore(root, maximumImageBytes: 2);

    await expectLater(
      store.stage(
        mediaItemId: 'media-1',
        book: _book,
        chapters: [_chapter],
        container: _Container({
          'OPS/image.png': Uint8List.fromList(<int>[1, 2, 3]),
        }),
      ),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.code,
          'code',
          'epub_resource_limit',
        ),
      ),
    );
    expect(
      Directory(
        '${root.path}${Platform.pathSeparator}staging'
        '${Platform.pathSeparator}media-1.tmp',
      ).existsSync(),
      isFalse,
    );
  });

  test('rejects unsafe IDs and content references', () async {
    final store = DartIoDerivedEpubStore(root);
    await expectLater(
      store.stage(
        mediaItemId: '../escape',
        book: _book,
        chapters: [_chapter],
        container: _Container(const {}),
      ),
      throwsArgumentError,
    );
    await expectLater(
      store.removeCommittedRef('../escape'),
      throwsArgumentError,
    );
  });
}

const _book = ParsedEpub(
  version: '3.0',
  packagePath: 'OPS/package.opf',
  title: '测试书',
  authors: ['作者'],
  manifest: {},
  spine: [],
  navigation: [],
);

final _chapter = EpubSemanticChapter(
  manifestId: 'chapter-1',
  sourcePath: 'OPS/chapter.xhtml',
  title: '第一章',
  linear: true,
  blocks: [
    EpubSemanticBlock.text(kind: EpubBlockKind.paragraph, text: '正文'),
    EpubSemanticBlock.image(
      imagePath: 'OPS/image.png',
      imageMediaType: 'image/png',
    ),
  ],
);

final class _Container implements EpubContainer {
  _Container(this.files);
  final Map<String, Uint8List> files;
  final reads = <String>[];

  @override
  List<EpubContainerEntry> get entries => const [];
  @override
  bool contains(String path) => files.containsKey(path);
  @override
  String resolvePath(String baseFilePath, String reference) => reference;
  @override
  Future<Uint8List> readBytes(String path) async {
    reads.add(path);
    return files[path]!;
  }

  @override
  Future<void> close() async {}
}
