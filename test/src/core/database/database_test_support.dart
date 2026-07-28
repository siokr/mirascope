import 'package:drift/native.dart';
import 'package:mirascope/src/core/database/app_database.dart';

AppDatabase createTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}
