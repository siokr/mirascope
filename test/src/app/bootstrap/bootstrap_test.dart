import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:mirascope/src/app/app.dart';
import 'package:mirascope/src/app/bootstrap/bootstrap.dart';
import 'package:mirascope/src/app/bootstrap/startup_error_app.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/core/database/database_providers.dart';

void main() {
  testWidgets(
    'successful initialization builds the app with its database override',
    (tester) async {
      final database = _TrackingAppDatabase();
      addTearDown(() async {
        if (database.closeCount == 0) {
          await database.close();
        }
      });

      final root = await buildRootWidget(
        initialize: () async => AppDependencies(database: database),
      );

      await tester.pumpWidget(root);
      await tester.pumpAndSettle();

      final appContext = tester.element(find.byType(MirascopeApp));
      final container = ProviderScope.containerOf(appContext);

      expect(find.byType(MirascopeApp), findsOneWidget);
      expect(container.read(appDatabaseProvider), same(database));
    },
  );

  testWidgets('unmounting ProviderScope closes its database exactly once', (
    tester,
  ) async {
    final database = _TrackingAppDatabase();
    addTearDown(() async {
      if (database.closeCount == 0) {
        await database.close();
      }
    });

    final root = await buildRootWidget(
      initialize: () async => AppDependencies(database: database),
    );

    await tester.pumpWidget(root);
    final appContext = tester.element(find.byType(MirascopeApp));
    ProviderScope.containerOf(appContext).read(appDatabaseProvider);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(database.closeCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(database.closeCount, 1);
  });

  testWidgets('database factory failure builds a safe database error', (
    tester,
  ) async {
    const privatePath = r'C:\Users\private\mirascope.sqlite';
    final records = <LogRecord>[];
    final subscription = Logger.root.onRecord.listen(records.add);
    addTearDown(subscription.cancel);

    final root = await buildRootWidget(
      initialize: () async => throw StateError(privatePath),
    );

    await tester.pumpWidget(root);

    expect(find.byType(StartupErrorApp), findsOneWidget);
    expect(find.text('应用启动失败'), findsOneWidget);
    expect(find.text('database_open_failed'), findsOneWidget);
    expect(find.textContaining(privatePath), findsNothing);
    expect(find.textContaining('没有修改或删除'), findsNothing);
    expect(records, hasLength(1));
    expect(records.single.message, 'database_open_failed');
    expect(records.single.error, isNull);
    expect(records.single.stackTrace, isNull);
    expect(records.single.toString(), isNot(contains(privatePath)));
  });

  testWidgets('a partially opened database is closed before the safe error', (
    tester,
  ) async {
    const privatePath = r'C:\Users\private\mirascope.sqlite';
    final database = _TrackingAppDatabase(
      setup: (_) => throw StateError(privatePath),
    );

    final root = await buildRootWidget(openDatabase: () => database);

    await tester.pumpWidget(root);

    expect(find.byType(StartupErrorApp), findsOneWidget);
    expect(find.text('database_open_failed'), findsOneWidget);
    expect(database.closeCount, 1);
  });

  testWidgets('foundation failure keeps the generic startup error semantics', (
    tester,
  ) async {
    const privatePath = r'C:\Users\private\foundation.json';
    final records = <LogRecord>[];
    final subscription = Logger.root.onRecord.listen(records.add);
    addTearDown(subscription.cancel);

    final root = await buildRootWidget(
      initializeFoundation: () async => throw StateError(privatePath),
    );

    await tester.pumpWidget(root);

    expect(find.byType(StartupErrorApp), findsOneWidget);
    expect(find.text('startup_failed'), findsOneWidget);
    expect(find.textContaining(privatePath), findsNothing);
    expect(records, hasLength(1));
    expect(records.single.message, 'startup_failed');
    expect(records.single.error, isNull);
    expect(records.single.stackTrace, isNull);
  });
}

final class _TrackingAppDatabase extends AppDatabase {
  _TrackingAppDatabase({DatabaseSetup? setup})
    : super(NativeDatabase.memory(setup: setup));

  int closeCount = 0;

  @override
  Future<void> close() {
    closeCount += 1;
    return super.close();
  }
}
