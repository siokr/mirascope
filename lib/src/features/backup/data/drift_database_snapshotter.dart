import 'dart:io';

import '../../../core/database/app_database.dart';

final class DriftDatabaseSnapshotter {
  const DriftDatabaseSnapshotter(this.database);

  final AppDatabase database;

  Future<void> call(File target) async {
    if (await target.exists()) {
      throw StateError('database_snapshot_target_exists');
    }
    await target.parent.create(recursive: true);
    await database.customStatement('VACUUM INTO ?', [target.path]);
  }
}
