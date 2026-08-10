import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_error_code.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/application/prepare_manga_source.dart';
import 'package:mirascope/src/features/importing/domain/import_record.dart';
import 'package:mirascope/src/features/importing/domain/import_repository.dart';
import 'package:mirascope/src/features/importing/domain/manga_source.dart';
import 'package:mirascope/src/features/importing/domain/successful_import.dart';

void main() {
  final candidate = MangaSourceCandidate(
    path: 'comic.cbz',
    kind: MangaSourceKind.archive,
    fileSize: 20,
    modifiedAt: DateTime.utc(2026),
    fingerprint: 'sha256:digest:20',
    imageCount: 0,
  );

  test('cancelled selection does not inspect or query duplicates', () async {
    final inspector = _FakeInspector(candidate);
    final repository = _FakeImportRepository();
    final result = await PrepareMangaSource(
      sourcePicker: const _FakePicker(),
      sourceInspector: inspector,
      importRepository: repository,
    )(MangaSourceKind.directory);

    expect(result, isA<MangaSourceCancelled>());
    expect(inspector.selections, isEmpty);
    expect(repository.fingerprints, isEmpty);
  });

  test('archive selection returns a ready candidate', () async {
    final inspector = _FakeInspector(candidate);
    final result = await PrepareMangaSource(
      sourcePicker: const _FakePicker(archivePath: 'comic.cbz'),
      sourceInspector: inspector,
      importRepository: _FakeImportRepository(),
    )(MangaSourceKind.archive);

    expect(result, isA<MangaSourceReady>());
    expect((result as MangaSourceReady).candidate, same(candidate));
    expect(inspector.selections.single.kind, MangaSourceKind.archive);
  });

  test('completed fingerprint returns the existing media item', () async {
    final result = await PrepareMangaSource(
      sourcePicker: const _FakePicker(archivePath: 'comic.cbz'),
      sourceInspector: _FakeInspector(candidate),
      importRepository: _FakeImportRepository(existing: _completedRecord()),
    )(MangaSourceKind.archive);

    expect(result, isA<MangaSourceDuplicate>());
    expect((result as MangaSourceDuplicate).mediaItemId, 'existing-manga');
  });

  test('safe source failure is preserved', () async {
    final result = await PrepareMangaSource(
      sourcePicker: const _FakePicker(directoryPath: 'comic'),
      sourceInspector: _ThrowingInspector(
        AppFailure.fromCode(AppErrorCode.mangaNoImages),
      ),
      importRepository: _FakeImportRepository(),
    )(MangaSourceKind.directory);

    expect(result, isA<MangaSourceFailed>());
    expect((result as MangaSourceFailed).failure.code, 'manga_no_images');
  });
}

final class _FakePicker implements MangaSourcePicker {
  const _FakePicker({this.archivePath, this.directoryPath});

  final String? archivePath;
  final String? directoryPath;

  @override
  Future<String?> pickArchive() async => archivePath;

  @override
  Future<String?> pickDirectory() async => directoryPath;
}

final class _FakeInspector implements MangaSourceInspector {
  _FakeInspector(this.candidate);

  final MangaSourceCandidate candidate;
  final selections = <MangaSourceSelection>[];

  @override
  Future<MangaSourceCandidate> inspect(MangaSourceSelection selection) async {
    selections.add(selection);
    return candidate;
  }
}

final class _ThrowingInspector implements MangaSourceInspector {
  const _ThrowingInspector(this.error);

  final Object error;

  @override
  Future<MangaSourceCandidate> inspect(MangaSourceSelection selection) async {
    throw error;
  }
}

final class _FakeImportRepository implements ImportRepository {
  _FakeImportRepository({this.existing});

  final ImportRecord? existing;
  final fingerprints = <String>[];

  @override
  Future<ImportRecord?> findCompletedByFingerprint(String fingerprint) async {
    fingerprints.add(fingerprint);
    return existing;
  }

  @override
  Future<void> commitSuccessfulImport(
    SuccessfulImport value, {
    Future<void> Function()? beforeCommit,
  }) async => throw UnimplementedError();

  @override
  Future<void> recordFailure(ImportRecord record) async {
    throw UnimplementedError();
  }
}

ImportRecord _completedRecord() => ImportRecord(
  id: 'existing-import',
  mediaItemId: 'existing-manga',
  sourcePath: 'old.cbz',
  sourceKind: ImportSourceKind.mangaArchive,
  fileSize: 20,
  modifiedAt: DateTime.utc(2026),
  fingerprint: 'sha256:digest:20',
  status: ImportStatus.completed,
  createdAt: DateTime.utc(2026),
);
