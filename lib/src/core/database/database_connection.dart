import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

AppDatabase openAppDatabase() {
  return AppDatabase(
    driftDatabase(
      name: 'mirascope',
      native: DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    ),
  );
}
