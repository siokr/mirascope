import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirascope/src/app/app.dart';
import 'package:mirascope/src/app/bootstrap/startup_error_app.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/core/database/database_connection.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/core/errors/app_error_code.dart';
import 'package:mirascope/src/core/logging/app_logger.dart';

final class AppDependencies {
  const AppDependencies({required this.database});

  final AppDatabase database;
}

typedef AppInitializer = Future<AppDependencies> Function();
typedef AppDatabaseFactory = AppDatabase Function();
typedef FoundationInitializer = Future<void> Function();

Future<Widget> buildRootWidget({
  AppInitializer? initialize,
  AppDatabaseFactory openDatabase = openAppDatabase,
  FoundationInitializer? initializeFoundation,
}) async {
  initializeAppLogging();

  try {
    await (initializeFoundation ?? _initializeFoundation)();
  } on Object {
    logAppError(AppErrorCode.startupFailed.value, stage: 'foundation');
    return StartupErrorApp(code: AppErrorCode.startupFailed.value);
  }

  late final AppDependencies dependencies;
  try {
    dependencies =
        await (initialize ?? () => _initializeDatabase(openDatabase))();
  } on Object {
    logAppError(AppErrorCode.databaseOpenFailed.value, stage: 'database_open');
    return StartupErrorApp(code: AppErrorCode.databaseOpenFailed.value);
  }

  return _buildApplication(dependencies.database);
}

Future<void> _initializeFoundation() async {}

Future<AppDependencies> _initializeDatabase(
  AppDatabaseFactory openDatabase,
) async {
  AppDatabase? database;
  try {
    database = openDatabase();
    await database.customSelect('SELECT 1').getSingle();
    return AppDependencies(database: database);
  } on Object {
    await database?.close();
    rethrow;
  }
}

Widget _buildApplication(AppDatabase database) {
  var isClosed = false;

  Future<void> closeDatabase() {
    if (isClosed) {
      return Future<void>.value();
    }
    isClosed = true;
    return database.close();
  }

  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWith((ref) {
        ref.onDispose(closeDatabase);
        return database;
      }),
      closeAppDatabaseProvider.overrideWithValue(closeDatabase),
    ],
    child: Consumer(
      builder: (context, ref, child) {
        ref.watch(appDatabaseProvider);
        return child!;
      },
      child: const MirascopeApp(),
    ),
  );
}
