import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/app/app.dart';
import 'package:mirascope/src/app/routing/app_router.dart';
import 'package:mirascope/src/app/routing/app_routes.dart';

void main() {
  testWidgets('opens settings from the library', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(MirascopeApp(router: router));
    await tester.pumpAndSettle();
    expect(find.text('媒体库'), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('媒体库'), findsOneWidget);
  });

  testWidgets('opens novel details with the media id', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(MirascopeApp(router: router));
    router.go('/novel/book-42');
    await tester.pumpAndSettle();

    expect(find.text('小说详情'), findsOneWidget);
    expect(find.text('媒体 ID：book-42'), findsOneWidget);
  });

  testWidgets('shows a safe page for an invalid media id', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(MirascopeApp(router: router));
    router.go('/novel/%20');
    await tester.pumpAndSettle();

    expect(find.text('无法打开该内容'), findsOneWidget);
    expect(find.text('返回媒体库'), findsOneWidget);

    await tester.tap(find.text('返回媒体库'));
    await tester.pumpAndSettle();

    expect(find.text('媒体库还是空的'), findsOneWidget);
  });

  testWidgets('opens the reader with the media id', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(MirascopeApp(router: router));
    router.go('/novel/book-42/read');
    await tester.pumpAndSettle();

    expect(find.text('阅读器'), findsOneWidget);
    expect(find.text('正在准备媒体：book-42'), findsOneWidget);
  });

  testWidgets('shows a safe page for an unknown path', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(MirascopeApp(router: router));
    router.go('/unknown');
    await tester.pumpAndSettle();

    expect(find.text('无法打开该内容'), findsOneWidget);
  });

  test('route helpers encode media ids as one path segment', () {
    expect(AppRoutes.novelDetails('folder/book 1'), '/novel/folder%2Fbook%201');
    expect(AppRoutes.novelReader('book?#1'), '/novel/book%3F%231/read');
  });
}
