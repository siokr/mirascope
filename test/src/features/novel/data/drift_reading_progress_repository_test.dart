import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/features/novel/data/drift_reading_progress_repository.dart';
import 'package:mirascope/src/features/novel/domain/progress_write_result.dart';
import 'package:mirascope/src/features/novel/domain/reading_progress.dart';

import '../../../core/database/database_test_support.dart';

final _now = DateTime.utc(2026, 7, 28, 11);

void main() {
  test('revision zero inserts the first progress for a media item', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _insertMediaAndContentUnit(database);
    final repository = DriftReadingProgressRepository(database);

    final result = await repository.save(_progress());
    final stored = await repository.findForMedia('media-one');

    expect(result, ProgressWriteResult.inserted);
    expect(stored?.id, 'progress-one');
    expect(stored?.mediaItemId, 'media-one');
    expect(stored?.contentUnitId, 'chapter-one');
    expect(stored?.locator, 'paragraph:1');
    expect(stored?.fraction, 0.25);
    expect(stored?.updatedAt, _now);
    expect(stored?.revision, 0);
  });

  test('the next revision updates and persists its locator', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _insertMediaAndContentUnit(database);
    final repository = DriftReadingProgressRepository(database);
    await repository.save(_progress());

    final result = await repository.save(
      _progress(
        locator: 'paragraph:8',
        fraction: 0.75,
        revision: 1,
        updatedAt: _now.add(const Duration(minutes: 1)),
      ),
    );
    final stored = await repository.findForMedia('media-one');

    expect(result, ProgressWriteResult.updated);
    expect(stored?.locator, 'paragraph:8');
    expect(stored?.fraction, 0.75);
    expect(stored?.updatedAt, _now.add(const Duration(minutes: 1)));
    expect(stored?.revision, 1);
  });

  test('a stale revision zero write cannot overwrite newer progress', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _insertMediaAndContentUnit(database);
    final repository = DriftReadingProgressRepository(database);
    await repository.save(_progress());
    await repository.save(
      _progress(locator: 'paragraph:8', fraction: 0.75, revision: 1),
    );

    final result = await repository.save(
      _progress(locator: 'stale', fraction: 0.1),
    );
    final stored = await repository.findForMedia('media-one');

    expect(result, ProgressWriteResult.revisionConflict);
    expect(stored?.locator, 'paragraph:8');
    expect(stored?.fraction, 0.75);
    expect(stored?.revision, 1);
  });

  test('revision one cannot create a missing progress row', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _insertMediaAndContentUnit(database);
    final repository = DriftReadingProgressRepository(database);

    final result = await repository.save(_progress(revision: 1));

    expect(result, ProgressWriteResult.revisionConflict);
    expect(await repository.findForMedia('media-one'), isNull);
  });

  test(
    'save rejects a content unit owned by another media item without writing',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      await _insertMediaAndContentUnit(database);
      await _insertMediaAndContentUnit(
        database,
        mediaItemId: 'media-two',
        contentUnitId: 'chapter-two',
      );
      final repository = DriftReadingProgressRepository(database);

      await expectLater(
        repository.save(_progress(contentUnitId: 'chapter-two')),
        throwsArgumentError,
      );

      expect(await repository.findForMedia('media-one'), isNull);
      expect(
        await database.select(database.readingProgressEntries).get(),
        isEmpty,
      );
    },
  );

  test('invalid progress is rejected before database access', () async {
    final database = createTestDatabase();
    await database.close();
    final repository = DriftReadingProgressRepository(database);

    for (final progress in [
      _progress(fraction: -0.01),
      _progress(fraction: 1.01),
      _progress(revision: -1),
    ]) {
      await expectLater(repository.save(progress), throwsArgumentError);
    }
  });
}

ReadingProgress _progress({
  String mediaItemId = 'media-one',
  String contentUnitId = 'chapter-one',
  String locator = 'paragraph:1',
  double fraction = 0.25,
  DateTime? updatedAt,
  int revision = 0,
}) {
  return ReadingProgress(
    id: 'progress-one',
    mediaItemId: mediaItemId,
    contentUnitId: contentUnitId,
    locator: locator,
    fraction: fraction,
    updatedAt: updatedAt ?? _now,
    revision: revision,
  );
}

Future<void> _insertMediaAndContentUnit(
  AppDatabase database, {
  String mediaItemId = 'media-one',
  String contentUnitId = 'chapter-one',
}) async {
  await database
      .into(database.mediaItems)
      .insert(
        MediaItemsCompanion.insert(
          id: mediaItemId,
          mediaType: 'novel',
          title: 'Title $mediaItemId',
          createdAt: _now,
          updatedAt: _now,
        ),
      );
  await database
      .into(database.contentUnits)
      .insert(
        ContentUnitsCompanion.insert(
          id: contentUnitId,
          mediaItemId: mediaItemId,
          unitType: 'chapter',
          title: 'Chapter $contentUnitId',
          orderIndex: 0,
          contentRef: 'content/$contentUnitId',
          sourceLocator: 'source#$contentUnitId',
          contentHash: 'hash-$contentUnitId',
        ),
      );
}
