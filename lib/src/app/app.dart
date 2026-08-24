import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mirascope/src/app/routing/app_router.dart';
import 'package:mirascope/src/app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirascope/src/features/backup/application/restore_status.dart';

class MirascopeApp extends ConsumerStatefulWidget {
  const MirascopeApp({this.router, super.key});

  final GoRouter? router;

  @override
  ConsumerState<MirascopeApp> createState() => _MirascopeAppState();
}

class _MirascopeAppState extends ConsumerState<MirascopeApp> {
  late final GoRouter _router;
  late final bool _ownsRouter;

  @override
  void initState() {
    super.initState();
    _ownsRouter = widget.router == null;
    _router = widget.router ?? createAppRouter();
  }

  @override
  void dispose() {
    if (_ownsRouter) {
      _router.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restoreStatus = ref.watch(restoreStatusProvider);
    if (restoreStatus.phase != RestoreStatusPhase.idle) {
      return MaterialApp(
        title: 'mirascope',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: _RestoreStatusPage(status: restoreStatus),
      );
    }
    return MaterialApp.router(
      title: 'mirascope',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}

class _RestoreStatusPage extends ConsumerWidget {
  const _RestoreStatusPage({required this.status});

  final RestoreStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (title, message, busy) = switch (status.phase) {
      RestoreStatusPhase.preparing => ('正在准备恢复', '正在关闭媒体库页面，请勿关闭应用。', true),
      RestoreStatusPhase.staging => ('正在校验备份', '正在复验并暂存备份，请勿关闭应用。', true),
      RestoreStatusPhase.closingDatabase => (
        '正在关闭数据库',
        '正在安全释放本地数据库，请勿关闭应用。',
        true,
      ),
      RestoreStatusPhase.committing => ('正在写入备份', '正在原子替换应用数据，请勿关闭应用。', true),
      RestoreStatusPhase.succeeded => (
        '恢复完成',
        '备份数据已经恢复。请关闭并重新启动 Mirascope。',
        false,
      ),
      RestoreStatusPhase.rejected => ('恢复未开始', '备份在恢复前复验失败，当前数据未修改。', false),
      RestoreStatusPhase.restartRequired => (
        '恢复已准备',
        '备份已安全登记。请关闭并重新启动 Mirascope，应用会在打开数据库前完成恢复。',
        false,
      ),
      RestoreStatusPhase.manualRecovery => (
        '需要人工恢复',
        '自动回滚未完成。旧数据副本保存在：\n${status.recoveryDirectory}\n\n'
            '请勿删除该目录，并关闭 Mirascope。',
        false,
      ),
      RestoreStatusPhase.idle => throw StateError('idle uses the router'),
    };
    final rejected = status.phase == RestoreStatusPhase.rejected;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (busy) const CircularProgressIndicator(),
                  if (busy) const SizedBox(height: 24),
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center),
                  if (rejected) ...[
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () =>
                          ref.read(restoreStatusProvider.notifier).reset(),
                      child: const Text('返回设置'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
