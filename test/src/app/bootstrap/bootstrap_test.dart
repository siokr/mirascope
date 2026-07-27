import 'package:flutter_test/flutter_test.dart';
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
    final root = await buildRootWidget(
      initialize: () async => throw StateError('database path is private'),
    );

    await tester.pumpWidget(root);

    expect(find.byType(StartupErrorApp), findsOneWidget);
    expect(find.text('应用启动失败'), findsOneWidget);
    expect(find.text('startup_failed'), findsOneWidget);
    expect(find.textContaining('database path is private'), findsNothing);
  });
}
