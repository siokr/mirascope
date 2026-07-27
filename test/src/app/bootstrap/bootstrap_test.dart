import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:mirascope/src/app/app.dart';
import 'package:mirascope/src/app/bootstrap/bootstrap.dart';
import 'package:mirascope/src/app/bootstrap/startup_error_app.dart';

void main() {
  testWidgets('successful initialization builds the app', (tester) async {
    final root = await buildRootWidget(initialize: () async {});

    await tester.pumpWidget(root);
    await tester.pumpAndSettle();

    expect(find.byType(MirascopeApp), findsOneWidget);
  });

  testWidgets('failed initialization builds a safe startup error', (
    tester,
  ) async {
    final records = <LogRecord>[];
    final subscription = Logger.root.onRecord.listen(records.add);
    addTearDown(subscription.cancel);

    final root = await buildRootWidget(
      initialize: () async => throw StateError('database path is private'),
    );

    await tester.pumpWidget(root);

    expect(find.byType(StartupErrorApp), findsOneWidget);
    expect(find.text('应用启动失败'), findsOneWidget);
    expect(find.text('startup_failed'), findsOneWidget);
    expect(find.textContaining('database path is private'), findsNothing);
    expect(find.textContaining('没有修改或删除'), findsNothing);
    expect(records, hasLength(1));
    expect(records.single.message, 'startup_failed');
    expect(records.single.error, isNull);
    expect(records.single.stackTrace, isNull);
  });
}
