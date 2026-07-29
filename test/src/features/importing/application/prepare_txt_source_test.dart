import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_error_code.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';
import 'package:mirascope/src/features/importing/application/prepare_txt_source.dart';
import 'package:mirascope/src/features/importing/domain/import_record.dart';
import 'package:mirascope/src/features/importing/domain/import_repository.dart';
import 'package:mirascope/src/features/importing/domain/successful_import.dart';
import 'package:mirascope/src/features/importing/domain/txt_file_picker.dart';
import 'package:mirascope/src/features/importing/domain/txt_source_candidate.dart';

void main() {
  final candidate = TxtSourceCandidate(
    path: r'C:\books\novel.txt',
    fileSize: 3,
    modifiedAt: DateTime.utc(2026),
    fingerprint: 'sha256:digest:3',
  );

  test('cancelled picker does not inspect or query the repository', () async {
    final inspector = _FakeInspector(candidate);
    final repository = _FakeImportRepository();
    final useCase = PrepareTxtSource(
      filePicker: const _FakePicker(null),
      sourceInspector: inspector,
      importRepository: repository,
    );

    final result = await useCase();

    expect(result, isA<TxtSourceCancelled>());
    expect(inspector.paths, isEmpty);
    expect(repository.fingerprints, isEmpty);
  });

  test('new fingerprint returns a ready candidate', () async {
    final repository = _FakeImportRepository();
    final useCase = PrepareTxtSource(
      filePicker: _FakePicker(candidate.path),
      sourceInspector: _FakeInspector(candidate),
      importRepository: repository,
    );

    final result = await useCase();

    expect(result, isA<TxtSourceReady>());
    expect((result as TxtSourceReady).candidate, same(candidate));
    expect(repository.fingerprints, <String>[candidate.fingerprint]);
  });

  test('completed fingerprint returns the existing media id', () async {
    final repository = _FakeImportRepository(existing: _completedRecord());
    final useCase = PrepareTxtSource(
      filePicker: _FakePicker(candidate.path),
      sourceInspector: _FakeInspector(candidate),
      importRepository: repository,
    );

    final result = await useCase();

    expect(result, isA<TxtSourceDuplicate>());
    expect((result as TxtSourceDuplicate).mediaItemId, 'media-existing');
    expect(result.candidate, same(candidate));
  });

  test('safe inspector failure is preserved', () async {
    final useCase = PrepareTxtSource(
      filePicker: _FakePicker(candidate.path),
      sourceInspector: _ThrowingInspector(
        AppFailure.fromCode(AppErrorCode.emptyFile),
      ),
      importRepository: _FakeImportRepository(),
    );

    final result = await useCase();

    expect(result, isA<TxtSourceFailed>());
    expect((result as TxtSourceFailed).failure.code, 'empty_file');
  });

  test('unknown picker failure becomes storage_failed', () async {
    const privatePath = r'C:\Users\private\secret.txt';
    final useCase = PrepareTxtSource(
      filePicker: _ThrowingPicker(StateError(privatePath)),
      sourceInspector: _FakeInspector(candidate),
      importRepository: _FakeImportRepository(),
    );

    final result = await useCase();

    expect(result, isA<TxtSourceFailed>());
    final failure = (result as TxtSourceFailed).failure;
    expect(failure.code, 'storage_failed');
    expect(failure.toString(), isNot(contains(privatePath)));
  });
}

final class _FakePicker implements TxtFilePicker {
  const _FakePicker(this.path);

  final String? path;

  @override
  Future<String?> pickTxtFile() async => path;
}

final class _ThrowingPicker implements TxtFilePicker {
  const _ThrowingPicker(this.error);

  final Object error;

  @override
  Future<String?> pickTxtFile() async => throw error;
}

final class _FakeInspector implements TxtSourceInspector {
  _FakeInspector(this.candidate);

  final TxtSourceCandidate candidate;
  final paths = <String>[];

  @override
  Future<TxtSourceCandidate> inspect(String path) async {
    paths.add(path);
    return candidate;
  }
}

final class _ThrowingInspector implements TxtSourceInspector {
  const _ThrowingInspector(this.error);

  final Object error;

  @override
  Future<TxtSourceCandidate> inspect(String path) async => throw error;
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
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> recordFailure(ImportRecord record) async {
    throw UnimplementedError();
  }
}

ImportRecord _completedRecord() {
  return ImportRecord(
    id: 'import-existing',
    mediaItemId: 'media-existing',
    sourcePath: r'C:\old\novel.txt',
    sourceKind: ImportSourceKind.txtFile,
    fileSize: 3,
    modifiedAt: DateTime.utc(2026),
    fingerprint: 'sha256:digest:3',
    status: ImportStatus.completed,
    createdAt: DateTime.utc(2026),
  );
}
