import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/progress_write_result.dart';
import '../domain/reading_progress.dart' as domain;
import '../domain/reading_progress_repository.dart';

final class DriftReadingProgressRepository
    implements ReadingProgressRepository {
  DriftReadingProgressRepository(this.database);

  final AppDatabase database;

  @override
  Future<domain.ReadingProgress?> findForMedia(String mediaItemId) async {
    final row =
        await (database.select(database.readingProgressEntries)
              ..where((entry) => entry.mediaItemId.equals(mediaItemId)))
            .getSingleOrNull();

    return row == null ? null : _toDomain(row);
  }

  @override
  Future<ProgressWriteResult> save(domain.ReadingProgress progress) async {
    _validate(progress);

    return database.transaction(() async {
      await _validateContentUnitOwnership(progress);

      if (progress.revision == 0) {
        final affectedRows = await database.customUpdate(
          'INSERT OR IGNORE INTO reading_progress '
          '(id, media_item_id, content_unit_id, locator, fraction, updated_at, '
          'revision) VALUES (?, ?, ?, ?, ?, ?, ?)',
          variables: [
            Variable.withString(progress.id),
            Variable.withString(progress.mediaItemId),
            Variable.withString(progress.contentUnitId),
            Variable.withString(progress.locator),
            Variable.withReal(progress.fraction),
            Variable.withInt(progress.updatedAt.toUtc().millisecondsSinceEpoch),
            Variable.withInt(progress.revision),
          ],
          updates: {database.readingProgressEntries},
        );
        return affectedRows == 1
            ? ProgressWriteResult.inserted
            : ProgressWriteResult.revisionConflict;
      }

      final affectedRows =
          await (database.update(database.readingProgressEntries)..where(
                (row) =>
                    row.mediaItemId.equals(progress.mediaItemId) &
                    row.revision.equals(progress.revision - 1),
              ))
              .write(_companion(progress));
      return affectedRows == 1
          ? ProgressWriteResult.updated
          : ProgressWriteResult.revisionConflict;
    });
  }

  Future<void> _validateContentUnitOwnership(
    domain.ReadingProgress progress,
  ) async {
    final contentUnit =
        await (database.select(database.contentUnits)..where(
              (row) =>
                  row.id.equals(progress.contentUnitId) &
                  row.mediaItemId.equals(progress.mediaItemId),
            ))
            .getSingleOrNull();

    if (contentUnit == null) {
      throw ArgumentError.value(
        progress.contentUnitId,
        'progress.contentUnitId',
        'must belong to progress.mediaItemId',
      );
    }
  }

  void _validate(domain.ReadingProgress progress) {
    if (!progress.fraction.isFinite ||
        progress.fraction < 0 ||
        progress.fraction > 1) {
      throw ArgumentError.value(
        progress.fraction,
        'progress.fraction',
        'must be between 0 and 1',
      );
    }
    if (progress.revision < 0) {
      throw ArgumentError.value(
        progress.revision,
        'progress.revision',
        'must be non-negative',
      );
    }
  }

  ReadingProgressEntriesCompanion _companion(domain.ReadingProgress progress) {
    return ReadingProgressEntriesCompanion(
      id: Value(progress.id),
      mediaItemId: Value(progress.mediaItemId),
      contentUnitId: Value(progress.contentUnitId),
      locator: Value(progress.locator),
      fraction: Value(progress.fraction),
      updatedAt: Value(progress.updatedAt),
      revision: Value(progress.revision),
    );
  }

  domain.ReadingProgress _toDomain(ReadingProgressEntry row) {
    return domain.ReadingProgress(
      id: row.id,
      mediaItemId: row.mediaItemId,
      contentUnitId: row.contentUnitId,
      locator: row.locator,
      fraction: row.fraction,
      updatedAt: row.updatedAt,
      revision: row.revision,
    );
  }
}
