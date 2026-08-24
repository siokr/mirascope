import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mirascope/src/app/app.dart';
import 'package:mirascope/src/features/backup/application/restore_status.dart';

void main() {
  testWidgets('restore mode unmounts routed database consumers', (
    tester,
  ) async {
    late WidgetRef ref;
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('数据库页面')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, value, child) {
            ref = value;
            return MirascopeApp(router: router);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('数据库页面'), findsOneWidget);

    ref.read(restoreStatusProvider.notifier).begin();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('数据库页面'), findsNothing);
    expect(find.text('正在准备恢复'), findsOneWidget);
    expect(find.textContaining('请勿关闭应用'), findsOneWidget);
  });
}
