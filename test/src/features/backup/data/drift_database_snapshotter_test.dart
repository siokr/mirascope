import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/features/backup/data/drift_database_snapshotter.dart';

void main() {
  test('creates a consistent SQLite snapshot from the live database', () async {
    final root = await Directory.systemTemp.createTemp('backup-db-test-');
    addTearDown(() => root.delete(recursive: true));
    final live = AppDatabase.inMemory();
    await live.customStatement(
      "INSERT INTO media_items "
      "(id, media_type, title, created_at, updated_at) "
      "VALUES ('book', 'novel', 'Snapshot Book', 1, 1)",
    );
    final snapshotFile = File(
      '${root.path}${Platform.pathSeparator}mirascope.sqlite',
    );

    await DriftDatabaseSnapshotter(live).call(snapshotFile);
    await live.close();

    final snapshot = AppDatabase(NativeDatabase(snapshotFile));
    addTearDown(snapshot.close);
    final row = await snapshot
        .customSelect("SELECT title FROM media_items WHERE id = 'book'")
        .getSingle();
    expect(row.read<String>('title'), 'Snapshot Book');
    expect(
      await snapshot
          .customSelect('PRAGMA integrity_check')
          .getSingle()
          .then((row) => row.data.values.single),
      'ok',
    );
  });
}
