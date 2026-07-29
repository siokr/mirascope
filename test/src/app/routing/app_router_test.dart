import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mirascope/src/app/app.dart';
import 'package:mirascope/src/app/routing/app_router.dart';
import 'package:mirascope/src/app/routing/app_routes.dart';
import 'package:mirascope/src/core/database/database_providers.dart';

import '../../features/library/library_test_support.dart';

void main() {
  testWidgets('opens settings from the library', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final repository = FakeMediaLibraryRepository();
    addTearDown(() {
      repository.close();
    });

    await _pumpApp(tester, router, repository);
    expect(find.text('媒体库'), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-settings')));
    await _pumpRoute(tester);

    expect(find.text('设置'), findsOneWidget);

    await tester.pageBack();
    await _pumpRoute(tester);

    expect(find.text('媒体库'), findsOneWidget);
  });

  testWidgets('opens the archived library and returns', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final repository = FakeMediaLibraryRepository();
    addTearDown(() {
      repository.close();
    });

    await _pumpApp(tester, router, repository);
    await tester.tap(find.byKey(const Key('open-archive')));
    repository.archivedController.add([]);
    await _pumpRoute(tester);

    expect(find.text('已归档'), findsOneWidget);

    await tester.pageBack();
    await _pumpRoute(tester);
    expect(find.text('媒体库'), findsOneWidget);
  });

  testWidgets('opens novel details with the media id', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final repository = FakeMediaLibraryRepository();
    addTearDown(() {
      repository.close();
    });

    await _pumpApp(tester, router, repository);
    router.go('/novel/book-42');
    await _pumpRoute(tester);

    expect(find.text('小说详情'), findsOneWidget);
    expect(find.text('媒体 ID：book-42'), findsOneWidget);
  });

  testWidgets('shows a safe page for an invalid media id', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final repository = FakeMediaLibraryRepository();
    addTearDown(() {
      repository.close();
    });

    await _pumpApp(tester, router, repository);
    router.go('/novel/%20');
    await _pumpRoute(tester);

    expect(find.text('无法打开该内容'), findsOneWidget);
    expect(find.text('返回媒体库'), findsOneWidget);

    await tester.tap(find.text('返回媒体库'));
    await _pumpRoute(tester);

    expect(find.text('媒体库还是空的'), findsOneWidget);
  });

  testWidgets('opens the reader with the media id', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final repository = FakeMediaLibraryRepository();
    addTearDown(() {
      repository.close();
    });

    await _pumpApp(tester, router, repository);
    router.go('/novel/book-42/read');
    await _pumpRoute(tester);

    expect(find.text('阅读器'), findsOneWidget);
    expect(find.text('正在准备媒体：book-42'), findsOneWidget);
  });

  testWidgets('shows a safe page for an unknown path', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final repository = FakeMediaLibraryRepository();
    addTearDown(() {
      repository.close();
    });

    await _pumpApp(tester, router, repository);
    router.go('/unknown');
    await _pumpRoute(tester);

    expect(find.text('无法打开该内容'), findsOneWidget);
  });

  test('route helpers encode media ids as one path segment', () {
    expect(AppRoutes.novelDetails('folder/book 1'), '/novel/folder%2Fbook%201');
    expect(AppRoutes.novelReader('book?#1'), '/novel/book%3F%231/read');
  });
}

Future<void> _pumpApp(
  WidgetTester tester,
  GoRouter router,
  FakeMediaLibraryRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [mediaLibraryRepositoryProvider.overrideWithValue(repository)],
      child: MirascopeApp(router: router),
    ),
  );
  repository.activeController.add([]);
  await _pumpRoute(tester);
}

Future<void> _pumpRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}
