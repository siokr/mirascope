import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/importing/application/relocate_epub_source.dart';
import 'package:mirascope/src/features/importing/application/relocate_txt_source.dart';
import 'package:mirascope/src/features/importing/domain/epub_file_picker.dart';
import 'package:mirascope/src/features/importing/domain/epub_source_candidate.dart';
import 'package:mirascope/src/features/importing/domain/import_record.dart';
import 'package:mirascope/src/features/importing/domain/source_candidate.dart';
import 'package:mirascope/src/features/importing/domain/source_relocation_repository.dart';

void main() {
  test('matching EPUB fingerprint restores the source location', () async {
    final repository = _Repository(_current);
    final result = await RelocateEpubSource(
      filePicker: const _Picker('moved.epub'),
      sourceInspector: _Inspector(_matching),
      repository: repository,
    )('media-1');

    expect(result, isA<SourceRelocated>());
    expect(repository.requestedKind, ImportSourceKind.epubFile);
    expect(repository.relocated?.path, 'moved.epub');
  });

  test('changed EPUB fingerprint preserves the current source', () async {
    final repository = _Repository(_current);
    final result = await RelocateEpubSource(
      filePicker: const _Picker('changed.epub'),
      sourceInspector: _Inspector(
        EpubSourceCandidate(
          path: 'changed.epub',
          fileSize: 5,
          modifiedAt: _date,
          fingerprint: 'different',
        ),
      ),
      repository: repository,
    )('media-1');

    expect(result, isA<SourceChangeConfirmationRequired>());
    expect(repository.relocated, isNull);
  });
}

final _date = DateTime.utc(2026, 8, 7);
final _matching = EpubSourceCandidate(
  path: 'moved.epub',
  fileSize: 4,
  modifiedAt: _date,
  fingerprint: 'same',
);
final _current = ImportRecord(
  id: 'import-1',
  mediaItemId: 'media-1',
  sourcePath: 'old.epub',
  sourceKind: ImportSourceKind.epubFile,
  fileSize: 4,
  modifiedAt: _date,
  fingerprint: 'same',
  status: ImportStatus.missing,
  createdAt: _date,
);

final class _Picker implements EpubFilePicker {
  const _Picker(this.path);
  final String? path;
  @override
  Future<String?> pickEpubFile() async => path;
}

final class _Inspector implements EpubSourceInspector {
  const _Inspector(this.candidate);
  final EpubSourceCandidate candidate;
  @override
  Future<EpubSourceCandidate> inspect(String path) async => candidate;
}

final class _Repository implements SourceRelocationRepository {
  _Repository(this.current);
  final ImportRecord? current;
  ImportSourceKind? requestedKind;
  SourceCandidate? relocated;

  @override
  Future<ImportRecord?> findLatestSourceForMedia(
    String mediaItemId, {
    ImportSourceKind sourceKind = ImportSourceKind.txtFile,
  }) async {
    requestedKind = sourceKind;
    return current;
  }

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
    relocated = candidate;
  }
}
