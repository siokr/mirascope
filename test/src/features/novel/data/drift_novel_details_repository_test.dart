import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/features/novel/data/drift_novel_details_repository.dart';

import '../../../core/database/database_test_support.dart';

void main() {
  test(
    'loads chapters in stable order and checks the completed source',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final checkedPaths = <String>[];
      final repository = DriftNovelDetailsRepository(
        database,
        sourceExists: (path) async {
          checkedPaths.add(path);
          return true;
        },
      );
      await _seed(database);

      final details = await repository.findDetails('media-1');

      expect(details?.mediaItem.title, 'Book');
      expect(details?.chapters.map((chapter) => chapter.title), [
        'First',
        'Second',
      ]);
      expect(details?.sourceAvailable, isTrue);
      expect(checkedPaths, ['private/source.txt']);
    },
  );

  test('missing media returns null without checking a path', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    var checked = false;
    final repository = DriftNovelDetailsRepository(
      database,
      sourceExists: (_) async {
        checked = true;
        return true;
      },
    );

    expect(await repository.findDetails('missing'), isNull);
    expect(checked, isFalse);
  });

  test(
    'unavailable completed source is marked missing without deleting details',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final repository = DriftNovelDetailsRepository(
        database,
        sourceExists: (_) async => false,
      );
      await _seed(database);

      final details = await repository.findDetails('media-1');
      final source = await database.select(database.importRecords).getSingle();

      expect(details?.sourceAvailable, isFalse);
      expect(details?.chapters, hasLength(2));
      expect(source.status, 'missing');
      expect(await database.select(database.mediaItems).get(), hasLength(1));
      expect(await database.select(database.contentUnits).get(), hasLength(2));
    },
  );
}

Future<void> _seed(AppDatabase database) async {
  final now = DateTime.utc(2026, 7, 29);
  await database
      .into(database.mediaItems)
      .insert(
        MediaItemsCompanion.insert(
          id: 'media-1',
          mediaType: 'novel',
          title: 'Book',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database.batch((batch) {
    batch.insertAll(database.contentUnits, [
      ContentUnitsCompanion.insert(
        id: 'unit-2',
        mediaItemId: 'media-1',
        unitType: 'chapter',
        title: 'Second',
        orderIndex: 1,
        contentRef: 'content/book.txt',
        sourceLocator: 'txt-v1:10:12:20',
        contentHash: 'hash-2',
      ),
      ContentUnitsCompanion.insert(
        id: 'unit-1',
        mediaItemId: 'media-1',
        unitType: 'chapter',
        title: 'First',
        orderIndex: 0,
        contentRef: 'content/book.txt',
        sourceLocator: 'txt-v1:0:2:10',
        contentHash: 'hash-1',
      ),
    ]);
  });
  await database
      .into(database.importRecords)
      .insert(
        ImportRecordsCompanion.insert(
          id: 'import-1',
          mediaItemId: const Value('media-1'),
          sourcePath: 'private/source.txt',
          sourceKind: 'txtFile',
          fileSize: 20,
          fingerprint: 'sha256:test:20',
          textEncoding: const Value('utf8'),
          status: 'completed',
          createdAt: now,
        ),
      );
}
