import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/importing/application/relocate_txt_source.dart';
import 'package:mirascope/src/features/importing/domain/import_record.dart';
import 'package:mirascope/src/features/importing/domain/source_relocation_repository.dart';
import 'package:mirascope/src/features/importing/domain/source_candidate.dart';
import 'package:mirascope/src/features/importing/domain/txt_encoding.dart';
import 'package:mirascope/src/features/importing/domain/txt_file_picker.dart';
import 'package:mirascope/src/features/importing/domain/txt_source_candidate.dart';

void main() {
  final current = ImportRecord(
    id: 'import-1',
    mediaItemId: 'media-1',
    sourcePath: 'old.txt',
    sourceKind: ImportSourceKind.txtFile,
    fileSize: 3,
    modifiedAt: DateTime.utc(2026),
    fingerprint: 'same',
    textEncoding: TxtEncoding.utf8,
    status: ImportStatus.missing,
    createdAt: DateTime.utc(2026),
  );
  final matching = TxtSourceCandidate(
    path: 'moved.txt',
    fileSize: 3,
    modifiedAt: DateTime.utc(2026, 7, 29),
    fingerprint: 'same',
  );

  test('cancel leaves the source unchanged', () async {
    final repository = _FakeRelocationRepository(current);
    final result = await RelocateTxtSource(
      filePicker: const _Picker(null),
      sourceInspector: _Inspector(matching),
      repository: repository,
    )('media-1');

    expect(result, isA<SourceRelocationCancelled>());
    expect(repository.relocations, isEmpty);
  });

  test('matching fingerprint restores the source location', () async {
    final repository = _FakeRelocationRepository(current);
    final result = await RelocateTxtSource(
      filePicker: const _Picker('moved.txt'),
      sourceInspector: _Inspector(matching),
      repository: repository,
    )('media-1');

    expect(result, isA<SourceRelocated>());
    expect(repository.relocations, hasLength(1));
    expect(repository.relocations.single.path, 'moved.txt');
  });

  test(
    'changed fingerprint requires confirmation and writes nothing',
    () async {
      final repository = _FakeRelocationRepository(current);
      final changed = TxtSourceCandidate(
        path: 'changed.txt',
        fileSize: 4,
        modifiedAt: DateTime.utc(2026, 7, 29),
        fingerprint: 'different',
      );
      final result = await RelocateTxtSource(
        filePicker: const _Picker('changed.txt'),
        sourceInspector: _Inspector(changed),
        repository: repository,
      )('media-1');

      expect(result, isA<SourceChangeConfirmationRequired>());
      expect(
        (result as SourceChangeConfirmationRequired).failure.code,
        'source_changed',
      );
      expect(repository.relocations, isEmpty);
    },
  );

  test('missing import record returns a safe failure', () async {
    final result = await RelocateTxtSource(
      filePicker: const _Picker('moved.txt'),
      sourceInspector: _Inspector(matching),
      repository: _FakeRelocationRepository(null),
    )('media-1');

    expect(result, isA<SourceRelocationFailed>());
    expect((result as SourceRelocationFailed).failure.code, 'file_not_found');
  });
}

final class _Picker implements TxtFilePicker {
  const _Picker(this.path);
  final String? path;
  @override
  Future<String?> pickTxtFile() async => path;
}

final class _Inspector implements TxtSourceInspector {
  const _Inspector(this.candidate);
  final TxtSourceCandidate candidate;
  @override
  Future<TxtSourceCandidate> inspect(String path) async => candidate;
}

final class _FakeRelocationRepository implements SourceRelocationRepository {
  _FakeRelocationRepository(this.current);
  final ImportRecord? current;
  final relocations = <SourceCandidate>[];

  @override
  Future<ImportRecord?> findLatestSourceForMedia(
    String mediaItemId, {
    ImportSourceKind sourceKind = ImportSourceKind.txtFile,
  }) async => current;

  @override
  Future<void> markSourceMissing({
    required String importRecordId,
    required String mediaItemId,
  }) async {}

  @override
  Future<void> relocateMatchingSource({
    required String importRecordId,
    required String mediaItemId,
    required String expectedFingerprint,
    required SourceCandidate candidate,
  }) async {
    relocations.add(candidate);
  }
}
