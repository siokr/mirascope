import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/ids/id_generator.dart';
import 'package:mirascope/src/features/importing/application/decode_txt_source.dart';
import 'package:mirascope/src/features/importing/application/import_txt.dart';
import 'package:mirascope/src/features/importing/application/txt_chapter_detector.dart';
import 'package:mirascope/src/features/importing/application/txt_decoder.dart';
import 'package:mirascope/src/features/importing/domain/derived_txt_store.dart';
import 'package:mirascope/src/features/importing/domain/import_record.dart';
import 'package:mirascope/src/features/importing/domain/import_repository.dart';
import 'package:mirascope/src/features/importing/domain/successful_import.dart';
import 'package:mirascope/src/features/importing/domain/txt_encoding.dart';
import 'package:mirascope/src/features/importing/domain/txt_source_candidate.dart';
import 'package:mirascope/src/features/importing/domain/txt_source_reader.dart';

void main() {
  test('imports normalized chapters as one complete aggregate', () async {
    final repository = _Repository();
    final store = _Store();
    final useCase = _useCase(repository, store);

    final result = await useCase(candidate: _candidate, title: 'Book');

    expect(result, isA<TxtImportSucceeded>());
    expect(repository.success?.contentUnits, hasLength(2));
    expect(repository.success?.importRecord.textEncoding, TxtEncoding.utf8);
    expect(
      repository.success?.contentUnits.first.sourceLocator,
      'txt-v1:0:6:8',
    );
    expect(store.promoted, isTrue);
    expect(repository.failures, isEmpty);
  });

  test('promotion failure rolls back and records stable failure', () async {
    final repository = _Repository();
    final store = _Store(failPromotion: true);

    final result = await _useCase(repository, store)(
      candidate: _candidate,
      title: 'Book',
    );

    expect((result as TxtImportFailed).failure.code, 'storage_failed');
    expect(repository.success, isNull);
    expect(repository.failures.single.mediaItemId, isNull);
    expect(repository.failures.single.errorCode, 'storage_failed');
    expect(store.discarded, isTrue);
  });

  test(
    'duplicate returns existing media without decoding or staging',
    () async {
      final repository = _Repository(existing: _existing);
      final store = _Store();

      final result = await _useCase(repository, store)(
        candidate: _candidate,
        title: 'Book',
      );

      expect((result as TxtImportDuplicate).mediaItemId, 'existing-media');
      expect(store.staged, isFalse);
    },
  );
}

ImportTxt _useCase(_Repository repository, _Store store) {
  return ImportTxt(
    decodeTxtSource: DecodeTxtSource(
      sourceReader: const _Reader(),
      decoder: TxtDecoder(gb18030Decoder: const _GbDecoder()),
    ),
    chapterDetector: const TxtChapterDetector(),
    importRepository: repository,
    derivedTxtStore: store,
    idGenerator: _Ids(),
    clock: () => DateTime.utc(2026, 7, 29),
  );
}

final _candidate = TxtSourceCandidate(
  path: 'C:/private/book.txt',
  fileSize: 20,
  modifiedAt: _date,
  fingerprint: 'sha256:test:20',
);
final _date = DateTime.utc(2026, 7, 29);

final _existing = ImportRecord(
  id: 'existing-import',
  mediaItemId: 'existing-media',
  sourcePath: 'old.txt',
  sourceKind: ImportSourceKind.txtFile,
  fileSize: 20,
  fingerprint: 'sha256:test:20',
  textEncoding: TxtEncoding.utf8,
  status: ImportStatus.completed,
  createdAt: _date,
);

final class _Reader implements TxtSourceReader {
  const _Reader();
  @override
  Future<Uint8List> read(TxtSourceCandidate candidate) async =>
      Uint8List.fromList(utf8.encode('第1章 一\n甲\n第2章 二\n乙'));
}

final class _GbDecoder implements Gb18030Decoder {
  const _GbDecoder();
  @override
  Future<String> decode(List<int> bytes) => throw UnimplementedError();
}

final class _Ids implements IdGenerator {
  var value = 0;
  @override
  String newId() => 'id-${value++}';
}

final class _Store implements DerivedTxtStore {
  _Store({this.failPromotion = false});
  final bool failPromotion;
  bool staged = false;
  bool promoted = false;
  bool discarded = false;

  @override
  Future<StagedDerivedTxt> stage({
    required String mediaItemId,
    required String text,
  }) async {
    staged = true;
    return const StagedDerivedTxt(
      contentRef: 'derived/id-0.txt',
      temporaryToken: 'temp',
    );
  }

  @override
  Future<void> promote(StagedDerivedTxt staged) async {
    if (failPromotion) throw StateError('failed');
    promoted = true;
  }

  @override
  Future<void> discard(StagedDerivedTxt staged) async => discarded = true;

  @override
  Future<void> removeCommitted(StagedDerivedTxt staged) async {}

  @override
  Future<void> removeCommittedRef(String contentRef) async {}
}

final class _Repository implements ImportRepository {
  _Repository({this.existing});
  final ImportRecord? existing;
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
    success = value;
  }

  @override
  Future<void> recordFailure(ImportRecord record) async => failures.add(record);
}
