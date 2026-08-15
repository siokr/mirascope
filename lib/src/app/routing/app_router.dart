import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mirascope/src/app/routing/app_routes.dart';
import 'package:mirascope/src/features/library/presentation/archived_library_page.dart';
import 'package:mirascope/src/features/library/presentation/library_page.dart';
import 'package:mirascope/src/features/novel/presentation/novel_details_page.dart';
import 'package:mirascope/src/features/novel/presentation/novel_reader_page.dart';
import 'package:mirascope/src/features/settings/presentation/settings_page.dart';
import 'package:mirascope/src/features/manga/presentation/manga_details_page.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.library,
    routes: [
      GoRoute(path: '/', redirect: (_, _) => AppRoutes.library),
      GoRoute(
        path: AppRoutes.library,
        builder: (context, state) => LibraryPage(
          onOpenSettings: () => context.push(AppRoutes.settings),
          onOpenArchive: () => context.push(AppRoutes.libraryArchive),
          onOpenNovel: (mediaItemId) =>
              context.push(AppRoutes.novelDetails(mediaItemId)),
          onOpenManga: (mediaItemId) =>
              context.push(AppRoutes.mangaDetails(mediaItemId)),
        ),
      ),
      GoRoute(
        path: AppRoutes.libraryArchive,
        builder: (context, state) => const ArchivedLibraryPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/manga/:mediaItemId',
        builder: (context, state) {
          final mediaItemId = state.pathParameters['mediaItemId']?.trim() ?? '';
          if (mediaItemId.isEmpty) return const _InvalidMediaPage();
          return MangaDetailsPage(
            mediaItemId: mediaItemId,
            onOpenChapter: (_) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(const SnackBar(content: Text('漫画阅读器将在下一阶段接入')));
            },
          );
        },
      ),
      GoRoute(
        path: '/novel/:mediaItemId',
        builder: (context, state) {
          final mediaItemId = state.pathParameters['mediaItemId']?.trim() ?? '';
          if (mediaItemId.isEmpty) {
            return const _InvalidMediaPage();
          }
          return NovelDetailsPage(
            mediaItemId: mediaItemId,
            onStartReading: (contentUnitId) => context.push(
              AppRoutes.novelReader(mediaItemId, contentUnitId: contentUnitId),
            ),
          );
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
              return NovelReaderPage(
                mediaItemId: mediaItemId,
                initialContentUnitId: state.uri.queryParameters['chapter'],
                onExit: () => context.go(AppRoutes.library),
              );
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
