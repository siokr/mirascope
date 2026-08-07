import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_error_code.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/core/ids/id_generator.dart';
import 'package:mirascope/src/features/importing/application/import_epub.dart';
import 'package:mirascope/src/features/importing/domain/derived_epub_store.dart';
import 'package:mirascope/src/features/importing/domain/epub_container.dart';
import 'package:mirascope/src/features/importing/domain/epub_semantic_content.dart';
import 'package:mirascope/src/features/importing/domain/epub_source_candidate.dart';
import 'package:mirascope/src/features/importing/domain/import_record.dart';
import 'package:mirascope/src/features/importing/domain/import_repository.dart';
import 'package:mirascope/src/features/importing/domain/parsed_epub.dart';
import 'package:mirascope/src/features/importing/domain/successful_import.dart';

void main() {
  test('commits EPUB metadata and chapter aggregate atomically', () async {
    final repository = _Repository();
    final store = _Store();
    final container = _Container();

    final result = await _useCase(repository, store, container)(_candidate);

    expect(result, isA<EpubImportSucceeded>());
    expect(repository.success?.mediaItem.title, '测试书');
    expect(repository.success?.mediaItem.creator, '作者甲、作者乙');
    expect(repository.success?.contentUnits, hasLength(2));
    expect(
      repository.success?.contentUnits.last.sourceLocator,
      'epub-v1:chapter-2',
    );
    expect(
      repository.success?.importRecord.sourceKind,
      ImportSourceKind.epubFile,
    );
    expect(store.promoted, isTrue);
    expect(container.closed, isTrue);
  });

  test('duplicate skips opening and staging', () async {
    final repository = _Repository(existing: _existing);
    final store = _Store();
    final container = _Container();

    final result = await _useCase(repository, store, container)(_candidate);

    expect((result as EpubImportDuplicate).mediaItemId, 'existing-media');
    expect(container.opened, isFalse);
    expect(store.staged, isFalse);
  });

  test('promotion failure discards staging and records failure', () async {
    final repository = _Repository();
    final store = _Store(failPromotion: true);
    final container = _Container();

    final result = await _useCase(repository, store, container)(_candidate);

    expect((result as EpubImportFailed).failure.code, 'storage_failed');
    expect(store.discarded, isTrue);
    expect(repository.failures.single.errorCode, 'storage_failed');
    expect(container.closed, isTrue);
  });

  test('EPUB failure code survives and container is closed', () async {
    final repository = _Repository();
    final store = _Store();
    final container = _Container(failParse: true);

    final result = await _useCase(repository, store, container)(_candidate);

    expect((result as EpubImportFailed).failure.code, 'epub_drm_unsupported');
    expect(repository.failures.single.errorCode, 'epub_drm_unsupported');
    expect(container.closed, isTrue);
  });

  test('database failure removes already promoted content', () async {
    final repository = _Repository(failCommit: true);
    final store = _Store();
    final container = _Container();

    final result = await _useCase(repository, store, container)(_candidate);

    expect((result as EpubImportFailed).failure.code, 'storage_failed');
    expect(store.removed, isTrue);
  });
}

ImportEpub _useCase(
  _Repository repository,
  _Store store,
  _Container container,
) => ImportEpub(
  openContainer: (path) async {
    container.opened = true;
    return container;
  },
  parsePackage: (value) async {
    if (container.failParse) {
      throw AppFailure.fromCode(AppErrorCode.epubDrmUnsupported);
    }
    return _book;
  },
  normalizeContent: (value, book) async => _chapters,
  importRepository: repository,
  derivedEpubStore: store,
  idGenerator: _Ids(),
  clock: () => DateTime.utc(2026, 8, 7),
);

final _candidate = EpubSourceCandidate(
  path: 'C:/private/book.epub',
  fileSize: 42,
  modifiedAt: DateTime.utc(2026, 8, 7),
  fingerprint: 'sha256:test:42',
);

final _existing = ImportRecord(
  id: 'existing-import',
  mediaItemId: 'existing-media',
  sourcePath: 'old.epub',
  sourceKind: ImportSourceKind.epubFile,
  fileSize: 42,
  fingerprint: 'sha256:test:42',
  status: ImportStatus.completed,
  createdAt: DateTime.utc(2026, 8, 7),
);

final class _Container implements EpubContainer {
  _Container({this.failParse = false});
  final bool failParse;
  bool opened = false;
  bool closed = false;
  @override
  List<EpubContainerEntry> get entries => const [];
  @override
  bool contains(String path) => false;
  @override
  String resolvePath(String baseFilePath, String reference) => reference;
  @override
  Future<Uint8List> readBytes(String path) async => Uint8List(0);
  @override
  Future<void> close() async => closed = true;
}

final class _Store implements DerivedEpubStore {
  _Store({this.failPromotion = false});
  final bool failPromotion;
  bool staged = false;
  bool promoted = false;
  bool discarded = false;
  bool removed = false;

  @override
  Future<StagedDerivedEpub> stage({
    required String mediaItemId,
    required ParsedEpub book,
    required List<EpubSemanticChapter> chapters,
    required EpubContainer container,
  }) async {
    staged = true;
    return StagedDerivedEpub(
      mediaItemId: mediaItemId,
      temporaryToken: 'temp',
      chapters: const [
        DerivedEpubChapter(
          contentRef: 'epub/id-0/chapters/00000.json',
          contentHash: 'hash-1',
        ),
        DerivedEpubChapter(
          contentRef: 'epub/id-0/chapters/00001.json',
          contentHash: 'hash-2',
        ),
      ],
    );
  }

  @override
  Future<void> promote(StagedDerivedEpub staged) async {
    if (failPromotion) throw StateError('promotion failed');
    promoted = true;
  }

  @override
  Future<void> discard(StagedDerivedEpub staged) async => discarded = true;
  @override
  Future<void> removeCommitted(StagedDerivedEpub staged) async =>
      removed = true;
  @override
  Future<void> removeCommittedRef(String contentRef) async {}
}

final class _Repository implements ImportRepository {
  _Repository({this.existing, this.failCommit = false});
  final ImportRecord? existing;
  final bool failCommit;
  SuccessfulImport? success;
  final failures = <ImportRecord>[];

  @override
  Future<ImportRecord?> findCompletedByFingerprint(String fingerprint) async =>
      existing;

  @override
  Future<void> commitSuccessfulImport(
    SuccessfulImport value, {
    Future<void> Function()? beforeCommit,
  }) async {
    await beforeCommit?.call();
    if (failCommit) throw StateError('database failed');
    success = value;
  }

  @override
  Future<void> recordFailure(ImportRecord record) async => failures.add(record);
}

final class _Ids implements IdGenerator {
  var value = 0;
  @override
  String newId() => 'id-${value++}';
}

const _book = ParsedEpub(
  version: '3.0',
  packagePath: 'OPS/package.opf',
  title: '测试书',
  authors: ['作者甲', '作者乙'],
  manifest: {},
  spine: [],
  navigation: [],
);

final _chapters = [
  EpubSemanticChapter(
    manifestId: 'chapter-1',
    sourcePath: 'OPS/1.xhtml',
    title: '第一章',
    linear: true,
    blocks: [EpubSemanticBlock.text(kind: EpubBlockKind.paragraph, text: '一')],
  ),
  EpubSemanticChapter(
    manifestId: 'chapter-2',
    sourcePath: 'OPS/2.xhtml',
    title: '第二章',
    linear: true,
    blocks: [EpubSemanticBlock.text(kind: EpubBlockKind.paragraph, text: '二')],
  ),
];
