import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mirascope/src/app/routing/app_routes.dart';
import 'package:mirascope/src/features/library/presentation/library_page.dart';
import 'package:mirascope/src/features/novel/presentation/novel_details_page.dart';
import 'package:mirascope/src/features/novel/presentation/novel_reader_page.dart';
import 'package:mirascope/src/features/settings/presentation/settings_page.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.library,
    routes: [
      GoRoute(path: '/', redirect: (_, _) => AppRoutes.library),
      GoRoute(
        path: AppRoutes.library,
        builder: (context, state) =>
            LibraryPage(onOpenSettings: () => context.push(AppRoutes.settings)),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/novel/:mediaItemId',
        builder: (context, state) {
          final mediaItemId = state.pathParameters['mediaItemId']?.trim() ?? '';
          if (mediaItemId.isEmpty) {
            return const _InvalidMediaPage();
          }
          return NovelDetailsPage(mediaItemId: mediaItemId);
        },
        routes: [
          GoRoute(
            path: 'read',
            builder: (context, state) {
              final mediaItemId =
                  state.pathParameters['mediaItemId']?.trim() ?? '';
              if (mediaItemId.isEmpty) {
                return const _InvalidMediaPage();
              }
              return NovelReaderPage(mediaItemId: mediaItemId);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const _InvalidMediaPage(),
  );
}

class _InvalidMediaPage extends StatelessWidget {
  const _InvalidMediaPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('无法打开该内容')),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go(AppRoutes.library),
          child: const Text('返回媒体库'),
        ),
      ),
    );
  }
}
