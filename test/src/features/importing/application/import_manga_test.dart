import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/ids/id_generator.dart';
import 'package:mirascope/src/features/importing/application/import_manga.dart';
import 'package:mirascope/src/features/importing/domain/derived_manga_store.dart';
import 'package:mirascope/src/features/importing/domain/import_record.dart';
import 'package:mirascope/src/features/importing/domain/import_repository.dart';
import 'package:mirascope/src/features/importing/domain/manga_manifest.dart';
import 'package:mirascope/src/features/importing/domain/manga_source.dart';
import 'package:mirascope/src/features/importing/domain/successful_import.dart';
import 'package:mirascope/src/features/manga/domain/manga_page.dart';

void main() {
  test(
    'commits manga, chapters and pages after promoting derived content',
    () async {
      final repository = _Repository();
      final store = _Store();
      final result = await _useCase(repository, store)(_candidate);

      expect(result, isA<MangaImportSucceeded>());
      expect(repository.success?.mediaItem.title, '测试漫画');
      expect(repository.success?.contentUnits, hasLength(1));
      expect(repository.success?.mangaPages, hasLength(2));
      expect(repository.success?.mangaPages.last.orderIndex, 1);
      expect(
        repository.success?.importRecord.sourceKind,
        ImportSourceKind.mangaArchive,
      );
      expect(store.promoted, isTrue);
    },
  );

  test('duplicate skips scan and staging', () async {
    final repository = _Repository(existing: _existing);
    final store = _Store();
    var scanned = false;
    final useCase = ImportManga(
      loadManifest: (_) async {
        scanned = true;
        return _manifest;
      },
      loadPageBytes: (_, _) async => Uint8List.fromList([1]),
      importRepository: repository,
      derivedMangaStore: store,
      idGenerator: _Ids(),
      clock: () => _now,
    );
    final result = await useCase(_candidate);
    expect((result as MangaImportDuplicate).mediaItemId, 'existing');
    expect(scanned, isFalse);
    expect(store.staged, isFalse);
  });

  test('promotion failure discards staging and records failure', () async {
    final repository = _Repository();
    final store = _Store(failPromotion: true);
    final result = await _useCase(repository, store)(_candidate);
    expect((result as MangaImportFailed).failure.code, 'storage_failed');
    expect(store.discarded, isTrue);
    expect(repository.failures.single.errorCode, 'storage_failed');
  });

  test('database failure compensates already promoted content', () async {
    final repository = _Repository(failCommit: true);
    final store = _Store();
    final result = await _useCase(repository, store)(_candidate);
    expect(result, isA<MangaImportFailed>());
    expect(store.removed, isTrue);
  });
}

ImportManga _useCase(_Repository repository, _Store store) => ImportManga(
  loadManifest: (_) async => _manifest,
  loadPageBytes: (_, path) async => Uint8List.fromList([1, 2, 3]),
  importRepository: repository,
  derivedMangaStore: store,
  idGenerator: _Ids(),
  clock: () => _now,
);

final _now = DateTime.utc(2026, 8, 15);
final _candidate = MangaSourceCandidate(
  path: 'C:/漫画/测试漫画.cbz',
  kind: MangaSourceKind.archive,
  fileSize: 100,
  modifiedAt: _now,
  fingerprint: 'sha256:manga',
  imageCount: 2,
);
final _existing = ImportRecord(
  id: 'import',
  mediaItemId: 'existing',
  sourcePath: 'old.cbz',
  sourceKind: ImportSourceKind.mangaArchive,
  fileSize: 1,
  fingerprint: 'sha256:manga',
  status: ImportStatus.completed,
  createdAt: _now,
);
final _manifest = MangaManifest(
  chapters: [
    MangaManifestChapter(
      title: '第一话',
      pages: const [
        MangaManifestPage(
          sourcePath: '第一话/1.png',
          contentHash: 'sha256:1',
          imageType: MangaImageType.png,
          byteLength: 3,
          pixelWidth: 1,
          pixelHeight: 1,
        ),
        MangaManifestPage(
          sourcePath: '第一话/2.png',
          contentHash: 'sha256:2',
          imageType: MangaImageType.png,
          byteLength: 3,
          pixelWidth: 1,
          pixelHeight: 1,
        ),
      ],
    ),
  ],
  invalidImageCount: 0,
  ignoredFileCount: 0,
);

final class _Ids implements IdGenerator {
  var next = 0;
  @override
  String newId() => 'id-${next++}';
}

final class _Store implements DerivedMangaStore {
  _Store({this.failPromotion = false});
  final bool failPromotion;
  bool staged = false;
  bool promoted = false;
  bool discarded = false;
  bool removed = false;
  @override
  Future<StagedDerivedManga> stage({
    required String mediaItemId,
    required MangaManifest manifest,
    required Uint8List coverBytes,
  }) async {
    staged = true;
    return StagedDerivedManga(
      mediaItemId: mediaItemId,
      temporaryToken: 'temp',
      coverRef: 'manga/$mediaItemId/cover.png',
    );
  }

  @override
  Future<void> promote(StagedDerivedManga staged) async {
    if (failPromotion) throw StateError('fail');
    promoted = true;
  }

  @override
  Future<void> discard(StagedDerivedManga staged) async {
    discarded = true;
  }

  @override
  Future<void> removeCommitted(StagedDerivedManga staged) async {
    removed = true;
  }

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
    if (failCommit) throw StateError('fail');
    success = value;
  }

  @override
  Future<void> recordFailure(ImportRecord record) async {
    failures.add(record);
  }
}
