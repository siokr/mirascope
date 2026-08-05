import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_error_code.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/application/prepare_epub_source.dart';
import 'package:mirascope/src/features/importing/domain/epub_file_picker.dart';
import 'package:mirascope/src/features/importing/domain/epub_source_candidate.dart';
import 'package:mirascope/src/features/importing/domain/import_record.dart';
import 'package:mirascope/src/features/importing/domain/import_repository.dart';
import 'package:mirascope/src/features/importing/domain/successful_import.dart';

void main() {
  final candidate = EpubSourceCandidate(
    path: r'C:\books\novel.epub',
    fileSize: 20,
    modifiedAt: DateTime.utc(2026),
    fingerprint: 'sha256:digest:20',
  );

  test('cancelled picker does not inspect or query repository', () async {
    final inspector = _FakeInspector(candidate);
    final repository = _FakeImportRepository();
    final result = await PrepareEpubSource(
      filePicker: const _FakePicker(null),
      sourceInspector: inspector,
      importRepository: repository,
    )();

    expect(result, isA<EpubSourceCancelled>());
    expect(inspector.paths, isEmpty);
    expect(repository.fingerprints, isEmpty);
  });

  test('new fingerprint returns ready candidate', () async {
    final repository = _FakeImportRepository();
    final result = await PrepareEpubSource(
      filePicker: _FakePicker(candidate.path),
      sourceInspector: _FakeInspector(candidate),
      importRepository: repository,
    )();

    expect(result, isA<EpubSourceReady>());
    expect((result as EpubSourceReady).candidate, same(candidate));
    expect(repository.fingerprints, <String>[candidate.fingerprint]);
  });

  test('completed fingerprint returns existing media id', () async {
    final result = await PrepareEpubSource(
      filePicker: _FakePicker(candidate.path),
      sourceInspector: _FakeInspector(candidate),
      importRepository: _FakeImportRepository(existing: _completedRecord()),
    )();

    expect(result, isA<EpubSourceDuplicate>());
    expect((result as EpubSourceDuplicate).mediaItemId, 'media-existing');
    expect(result.candidate, same(candidate));
  });

  test('safe inspector failure is preserved', () async {
    final result = await PrepareEpubSource(
      filePicker: _FakePicker(candidate.path),
      sourceInspector: _ThrowingInspector(
        AppFailure.fromCode(AppErrorCode.epubInvalidContainer),
      ),
      importRepository: _FakeImportRepository(),
    )();

    expect(result, isA<EpubSourceFailed>());
    expect((result as EpubSourceFailed).failure.code, 'epub_invalid_container');
  });
}

final class _FakePicker implements EpubFilePicker {
  const _FakePicker(this.path);
  final String? path;

  @override
  Future<String?> pickEpubFile() async => path;
}

final class _FakeInspector implements EpubSourceInspector {
  _FakeInspector(this.candidate);
  final EpubSourceCandidate candidate;
  final paths = <String>[];

  @override
  Future<EpubSourceCandidate> inspect(String path) async {
    paths.add(path);
    return candidate;
  }
}

final class _ThrowingInspector implements EpubSourceInspector {
  const _ThrowingInspector(this.error);
  final Object error;

  @override
  Future<EpubSourceCandidate> inspect(String path) async => throw error;
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
  Future<void> recordFailure(ImportRecord record) async =>
      throw UnimplementedError();
}

ImportRecord _completedRecord() => ImportRecord(
  id: 'import-existing',
  mediaItemId: 'media-existing',
  sourcePath: r'C:\old\novel.epub',
  sourceKind: ImportSourceKind.epubFile,
  fileSize: 20,
  modifiedAt: DateTime.utc(2026),
  fingerprint: 'sha256:digest:20',
  status: ImportStatus.completed,
  createdAt: DateTime.utc(2026),
);
