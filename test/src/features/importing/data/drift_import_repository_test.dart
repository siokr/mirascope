import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/features/importing/data/drift_import_repository.dart';
import 'package:mirascope/src/features/importing/domain/import_record.dart'
    as domain_import;
import 'package:mirascope/src/features/importing/domain/successful_import.dart';
import 'package:mirascope/src/features/importing/domain/txt_encoding.dart';
import 'package:mirascope/src/features/library/domain/library_entry.dart'
    as domain;
import 'package:mirascope/src/features/library/domain/media_item.dart'
    as domain;
import 'package:mirascope/src/features/novel/domain/content_unit.dart'
    as domain;

import '../../../core/database/database_test_support.dart';

final _now = DateTime.utc(2026, 7, 28, 10);

void main() {
  test('successful commit writes the complete import aggregate', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftImportRepository(database);
    final value = _successfulImport();

    await repository.commitSuccessfulImport(value);

    final mediaRows = await database.select(database.mediaItems).get();
    final libraryRows = await database.select(database.libraryEntries).get();
    final contentRows = await database.select(database.contentUnits).get();
    final importRows = await database.select(database.importRecords).get();
    expect(mediaRows, hasLength(1));
    expect(mediaRows.single.id, 'media-one');
    expect(mediaRows.single.title, 'Title one');
    expect(libraryRows, hasLength(1));
    expect(libraryRows.single.id, 'library-one');
    expect(contentRows.map((row) => row.id).toList(), [
      'chapter-one-1',
      'chapter-one-2',
    ]);
    expect(importRows, hasLength(1));
    expect(importRows.single.id, 'import-one');
    expect(importRows.single.status, 'completed');
    expect(importRows.single.textEncoding, 'utf8');
  });

  test(
    'successful import keeps an immutable snapshot of caller chapters',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final repository = DriftImportRepository(database);
      final callerChapters = [
        _contentUnit(prefix: 'one', idSuffix: '1', orderIndex: 0),
        _contentUnit(prefix: 'one', idSuffix: '2', orderIndex: 1),
      ];
      final value = _successfulImport(contentUnits: callerChapters);

      callerChapters.clear();

      expect(value.contentUnits, hasLength(2));
      await repository.commitSuccessfulImport(value);
      final rows = await database.select(database.contentUnits).get();
      expect(rows.map((row) => row.id).toList(), [
        'chapter-one-1',
        'chapter-one-2',
      ]);
      expect(value.contentUnits.clear, throwsUnsupportedError);
    },
  );

  test('completed fingerprint lookup returns the mapped record', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftImportRepository(database);
    await repository.commitSuccessfulImport(
      _successfulImport(
        sourcePath: 'C:/library/book-one.txt',
        fingerprint: 'fingerprint-one',
      ),
    );

    final record = await repository.findCompletedByFingerprint(
      'fingerprint-one',
    );

    expect(record?.id, 'import-one');
    expect(record?.mediaItemId, 'media-one');
    expect(record?.sourcePath, 'C:/library/book-one.txt');
    expect(record?.sourceKind, domain_import.ImportSourceKind.txtFile);
    expect(record?.fileSize, 101);
    expect(record?.modifiedAt, _now);
    expect(record?.fingerprint, 'fingerprint-one');
    expect(record?.textEncoding, TxtEncoding.utf8);
    expect(record?.status, domain_import.ImportStatus.completed);
    expect(record?.errorCode, isNull);
    expect(record?.createdAt, _now);
  });

  test('the same fingerprint may exist at two source paths', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftImportRepository(database);

    await repository.commitSuccessfulImport(
      _successfulImport(
        prefix: 'first',
        sourcePath: 'C:/library/first.txt',
        fingerprint: 'shared-fingerprint',
      ),
    );
    await repository.commitSuccessfulImport(
      _successfulImport(
        prefix: 'second',
        sourcePath: 'D:/archive/second.txt',
        fingerprint: 'shared-fingerprint',
      ),
    );

    final rows = await database.select(database.importRecords).get();
    expect(rows, hasLength(2));
    expect(
      rows.map((row) => row.sourcePath),
      containsAll(['C:/library/first.txt', 'D:/archive/second.txt']),
    );
    expect(
      rows.map((row) => row.fingerprint),
      everyElement('shared-fingerprint'),
    );
  });

  test(
    'failed and missing fingerprints are not treated as completed',
    () async {
      for (final status in <domain_import.ImportStatus>[
        domain_import.ImportStatus.failed,
        domain_import.ImportStatus.missing,
      ]) {
        final database = createTestDatabase();
        final repository = DriftImportRepository(database);
        await repository.commitSuccessfulImport(
          _successfulImport(fingerprint: 'inactive-fingerprint'),
        );
        await (database.update(
          database.importRecords,
        )..where((row) => row.id.equals('import-one'))).write(
          ImportRecordsCompanion(
            status: Value(status.storageValue),
            errorCode: status == domain_import.ImportStatus.failed
                ? const Value('storage_failed')
                : const Value.absent(),
          ),
        );

        expect(
          await repository.findCompletedByFingerprint('inactive-fingerprint'),
          isNull,
          reason: '${status.storageValue} records must not block a new import',
        );
        await database.close();
      }
    },
  );

  test(
    'duplicate chapter order rolls back the whole successful import',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final repository = DriftImportRepository(database);
      final value = _successfulImport(
        contentUnits: [
          _contentUnit(prefix: 'one', idSuffix: '1', orderIndex: 0),
          _contentUnit(prefix: 'one', idSuffix: '2', orderIndex: 0),
        ],
      );

      await expectLater(
        repository.commitSuccessfulImport(value),
        throwsA(anything),
      );

      expect(await database.select(database.mediaItems).get(), isEmpty);
      expect(await database.select(database.libraryEntries).get(), isEmpty);
      expect(await database.select(database.contentUnits).get(), isEmpty);
      expect(await database.select(database.importRecords).get(), isEmpty);
    },
  );

  test('failed beforeCommit rolls back the complete aggregate', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftImportRepository(database);

    await expectLater(
      repository.commitSuccessfulImport(
        _successfulImport(),
        beforeCommit: () async {
          throw StateError('promotion_failed');
        },
      ),
      throwsA(isA<StateError>()),
    );

    expect(await database.select(database.mediaItems).get(), isEmpty);
    expect(await database.select(database.libraryEntries).get(), isEmpty);
    expect(await database.select(database.contentUnits).get(), isEmpty);
    expect(await database.select(database.importRecords).get(), isEmpty);
  });

  test('invalid successful imports throw before database access', () async {
    final database = createTestDatabase();
    await database.close();
    final repository = DriftImportRepository(database);
    final invalidValues = [
      _successfulImport(libraryMediaItemId: 'another-media'),
      _successfulImport(
        contentUnits: [
          _contentUnit(
            prefix: 'one',
            idSuffix: '1',
            orderIndex: 0,
            mediaItemId: 'another-media',
          ),
        ],
      ),
      _successfulImport(importMediaItemId: 'another-media'),
      _successfulImport(importStatus: domain_import.ImportStatus.pending),
      _successfulImport(contentUnits: const []),
    ];

    for (final value in invalidValues) {
      await expectLater(
        repository.commitSuccessfulImport(value),
        throwsArgumentError,
      );
    }
  });

  test(
    'recordFailure validates status and error code before database access',
    () async {
      final database = createTestDatabase();
      await database.close();
      final repository = DriftImportRepository(database);
      final invalidRecords = [
        _importRecord(
          status: domain_import.ImportStatus.completed,
          errorCode: 'parse',
        ),
        _importRecord(status: domain_import.ImportStatus.failed),
        _importRecord(status: domain_import.ImportStatus.failed, errorCode: ''),
        _importRecord(
          status: domain_import.ImportStatus.failed,
          errorCode: '   ',
        ),
      ];

      for (final record in invalidRecords) {
        await expectLater(
          repository.recordFailure(record),
          throwsArgumentError,
        );
      }
    },
  );

  test(
    'recordFailure writes a valid failed import without a media aggregate',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final repository = DriftImportRepository(database);
      await repository.recordFailure(
        _importRecord(
          linkedMedia: false,
          status: domain_import.ImportStatus.failed,
          errorCode: 'parse',
        ),
      );

      final rows = await database.select(database.importRecords).get();
      expect(rows, hasLength(1));
      expect(rows.single.id, 'import-one');
      expect(rows.single.mediaItemId, isNull);
      expect(rows.single.status, 'failed');
      expect(rows.single.errorCode, 'parse');
    },
  );
}

SuccessfulImport _successfulImport({
  String prefix = 'one',
  String sourcePath = 'C:/library/book.txt',
  String fingerprint = 'fingerprint-one',
  String? libraryMediaItemId,
  List<domain.ContentUnit>? contentUnits,
  String? importMediaItemId,
  domain_import.ImportStatus importStatus =
      domain_import.ImportStatus.completed,
}) {
  final mediaItemId = 'media-$prefix';
  return SuccessfulImport(
    mediaItem: domain.MediaItem(
      id: mediaItemId,
      mediaType: domain.MediaType.novel,
      title: 'Title $prefix',
      subtitle: 'Subtitle $prefix',
      creator: 'Creator $prefix',
      description: 'Description $prefix',
      coverRef: 'covers/$prefix',
      createdAt: _now,
      updatedAt: _now,
    ),
    libraryEntry: domain.LibraryEntry(
      id: 'library-$prefix',
      mediaItemId: libraryMediaItemId ?? mediaItemId,
      favorite: false,
      addedAt: _now,
    ),
    contentUnits:
        contentUnits ??
        [
          _contentUnit(prefix: prefix, idSuffix: '1', orderIndex: 0),
          _contentUnit(prefix: prefix, idSuffix: '2', orderIndex: 1),
        ],
    importRecord: _importRecord(
      prefix: prefix,
      mediaItemId: importMediaItemId ?? mediaItemId,
      sourcePath: sourcePath,
      fingerprint: fingerprint,
      status: importStatus,
    ),
  );
}

domain.ContentUnit _contentUnit({
  required String prefix,
  required String idSuffix,
  required int orderIndex,
  String? mediaItemId,
}) {
  return domain.ContentUnit(
    id: 'chapter-$prefix-$idSuffix',
    mediaItemId: mediaItemId ?? 'media-$prefix',
    unitType: domain.ContentUnitType.chapter,
    title: 'Chapter $idSuffix',
    orderIndex: orderIndex,
    contentRef: 'content/$prefix/$idSuffix',
    sourceLocator: 'source#$idSuffix',
    contentHash: 'hash-$prefix-$idSuffix',
  );
}

domain_import.ImportRecord _importRecord({
  String prefix = 'one',
  String? mediaItemId,
  bool linkedMedia = true,
  String sourcePath = 'C:/library/book.txt',
  String fingerprint = 'fingerprint-one',
  domain_import.ImportStatus status = domain_import.ImportStatus.completed,
  String? errorCode,
}) {
  return domain_import.ImportRecord(
    id: 'import-$prefix',
    mediaItemId: linkedMedia ? (mediaItemId ?? 'media-$prefix') : null,
    sourcePath: sourcePath,
    sourceKind: domain_import.ImportSourceKind.txtFile,
    fileSize: 101,
    modifiedAt: _now,
    fingerprint: fingerprint,
    textEncoding: TxtEncoding.utf8,
    status: status,
    errorCode: errorCode,
    createdAt: _now,
  );
}
