import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/import_record.dart' as domain;
import '../domain/import_repository.dart';
import '../domain/successful_import.dart';
import '../domain/txt_encoding.dart';

final class DriftImportRepository implements ImportRepository {
  DriftImportRepository(this.database);

  final AppDatabase database;

  @override
  Future<domain.ImportRecord?> findCompletedByFingerprint(
    String fingerprint,
  ) async {
    final query = database.select(database.importRecords)
      ..where(
        (row) =>
            row.fingerprint.equals(fingerprint) &
            row.status.equals(domain.ImportStatus.completed.storageValue),
      )
      ..limit(1);
    final record = await query.getSingleOrNull();

    return record == null ? null : _toImportRecord(record);
  }

  @override
  Future<void> commitSuccessfulImport(
    SuccessfulImport value, {
    Future<void> Function()? beforeCommit,
  }) async {
    _validateSuccessfulImport(value);

    await database.transaction(() async {
      await database
          .into(database.mediaItems)
          .insert(_mediaItemCompanion(value));
      await database
          .into(database.libraryEntries)
          .insert(_libraryEntryCompanion(value));
      await database.batch((batch) {
        batch.insertAll(
          database.contentUnits,
          value.contentUnits
              .map(
                (unit) => ContentUnitsCompanion.insert(
                  id: unit.id,
                  mediaItemId: unit.mediaItemId,
                  unitType: unit.unitType.storageValue,
                  title: unit.title,
                  orderIndex: unit.orderIndex,
                  contentRef: unit.contentRef,
                  sourceLocator: unit.sourceLocator,
                  contentHash: unit.contentHash,
                ),
              )
              .toList(),
        );
      });
      await database
          .into(database.importRecords)
          .insert(_importRecordCompanion(value.importRecord));
      await beforeCommit?.call();
    });
  }

  @override
  Future<void> recordFailure(domain.ImportRecord record) async {
    if (record.status != domain.ImportStatus.failed) {
      throw ArgumentError.value(
        record.status,
        'record.status',
        'A failure record must have failed status',
      );
    }
    if (record.errorCode == null || record.errorCode!.trim().isEmpty) {
      throw ArgumentError.value(
        record.errorCode,
        'record.errorCode',
        'A failure record requires a non-empty error code',
      );
    }

    await database
        .into(database.importRecords)
        .insert(_importRecordCompanion(record));
  }

  void _validateSuccessfulImport(SuccessfulImport value) {
    final mediaItemId = value.mediaItem.id;
    if (value.libraryEntry.mediaItemId != mediaItemId) {
      throw ArgumentError('libraryEntry.mediaItemId must equal mediaItem.id');
    }
    if (value.contentUnits.isEmpty) {
      throw ArgumentError('contentUnits must not be empty');
    }
    for (final contentUnit in value.contentUnits) {
      if (contentUnit.mediaItemId != mediaItemId) {
        throw ArgumentError(
          'Every contentUnit.mediaItemId must equal mediaItem.id',
        );
      }
    }
    if (value.importRecord.mediaItemId != mediaItemId) {
      throw ArgumentError('importRecord.mediaItemId must equal mediaItem.id');
    }
    if (value.importRecord.status != domain.ImportStatus.completed) {
      throw ArgumentError('importRecord.status must be completed');
    }
    if (value.importRecord.sourceKind == domain.ImportSourceKind.txtFile &&
        value.importRecord.textEncoding == null) {
      throw ArgumentError('A completed TXT import requires textEncoding');
    }
  }

  MediaItemsCompanion _mediaItemCompanion(SuccessfulImport value) {
    final mediaItem = value.mediaItem;
    return MediaItemsCompanion.insert(
      id: mediaItem.id,
      mediaType: mediaItem.mediaType.storageValue,
      title: mediaItem.title,
      subtitle: Value(mediaItem.subtitle),
      creator: Value(mediaItem.creator),
      description: Value(mediaItem.description),
      coverRef: Value(mediaItem.coverRef),
      createdAt: mediaItem.createdAt,
      updatedAt: mediaItem.updatedAt,
    );
  }

  LibraryEntriesCompanion _libraryEntryCompanion(SuccessfulImport value) {
    final libraryEntry = value.libraryEntry;
    return LibraryEntriesCompanion.insert(
      id: libraryEntry.id,
      mediaItemId: libraryEntry.mediaItemId,
      favorite: libraryEntry.favorite,
      addedAt: libraryEntry.addedAt,
      lastOpenedAt: Value(libraryEntry.lastOpenedAt),
      archivedAt: Value(libraryEntry.archivedAt),
    );
  }

  ImportRecordsCompanion _importRecordCompanion(domain.ImportRecord record) {
    return ImportRecordsCompanion.insert(
      id: record.id,
      mediaItemId: Value(record.mediaItemId),
      sourcePath: record.sourcePath,
      sourceKind: record.sourceKind.storageValue,
      fileSize: record.fileSize,
      modifiedAt: Value(record.modifiedAt),
      fingerprint: record.fingerprint,
      textEncoding: Value(record.textEncoding?.storageValue),
      status: record.status.storageValue,
      errorCode: Value(record.errorCode),
      createdAt: record.createdAt,
    );
  }

  domain.ImportRecord _toImportRecord(ImportRecord record) {
    return domain.ImportRecord(
      id: record.id,
      mediaItemId: record.mediaItemId,
      sourcePath: record.sourcePath,
      sourceKind: domain.ImportSourceKind.fromStorageValue(record.sourceKind),
      fileSize: record.fileSize,
      modifiedAt: record.modifiedAt,
      fingerprint: record.fingerprint,
      textEncoding: record.textEncoding == null
          ? null
          : TxtEncoding.fromStorageValue(record.textEncoding!),
      status: domain.ImportStatus.fromStorageValue(record.status),
      errorCode: record.errorCode,
      createdAt: record.createdAt,
    );
  }
}
