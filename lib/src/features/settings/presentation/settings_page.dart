import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/reader_settings_controller.dart';
import '../application/settings_providers.dart';
import '../../manga/application/manga_providers.dart';
import '../../backup/application/backup_providers.dart';
import '../../backup/application/export_backup.dart';
import '../../backup/application/preflight_backup.dart';
import '../../backup/application/restore_backup.dart';
import '../../backup/application/restore_status.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  var _exportingBackup = false;
  var _checkingBackup = false;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(globalReaderSettingsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: controller.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: OutlinedButton(
            onPressed: () =>
                ref.invalidate(globalReaderSettingsControllerProvider),
            child: const Text('重试'),
          ),
        ),
        data: (value) => _GlobalReaderSettings(
          controller: value,
          exportingBackup: _exportingBackup,
          exportBackup: _exportingBackup ? null : _exportBackup,
          checkingBackup: _checkingBackup,
          preflightBackup: _checkingBackup ? null : _preflightBackup,
          clearMangaCache: () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await (await ref.read(mangaPageCacheProvider.future)).clear();
              messenger.showSnackBar(
                const SnackBar(content: Text('漫画页面缓存已清理')),
              );
            } on Object {
              messenger.showSnackBar(
                const SnackBar(content: Text('清理失败，请稍后重试')),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _exportBackup() async {
    setState(() => _exportingBackup = true);
    ExportBackupResult result;
    try {
      result = await (await ref.read(exportBackupProvider.future))();
    } on Object {
      result = ExportBackupResult.failed;
    }
    if (!mounted) return;
    setState(() => _exportingBackup = false);
    final message = switch (result) {
      ExportBackupResult.succeeded => '备份已导出',
      ExportBackupResult.failed => '导出失败，请重试',
      ExportBackupResult.cancelled => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _preflightBackup() async {
    setState(() => _checkingBackup = true);
    final result = await ref.read(preflightBackupProvider)();
    if (!mounted) return;
    setState(() => _checkingBackup = false);
    switch (result) {
      case PreflightBackupCancelled():
        return;
      case PreflightBackupRejected(:final failure):
        final message = switch (failure) {
          PreflightBackupFailure.invalidBackup => '备份文件无效或已损坏',
          PreflightBackupFailure.incompatibleVersion => '备份来自更高版本，当前应用无法恢复',
        };
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      case PreflightBackupReady():
        final confirmed = await _showBackupPreview(result);
        if (confirmed == true) await _restoreBackup(result.sourcePath);
    }
  }

  Future<bool?> _showBackupPreview(PreflightBackupReady preview) async {
    final localDate = preview.createdAt.toLocal();
    final date =
        '${localDate.year.toString().padLeft(4, '0')}-'
        '${localDate.month.toString().padLeft(2, '0')}-'
        '${localDate.day.toString().padLeft(2, '0')}';
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('备份校验通过'),
        content: Text(
          '创建日期：$date\n'
          '数据库版本 ${preview.databaseSchemaVersion}\n'
          '包含 ${preview.fileCount} 个数据文件\n\n'
          '恢复会替换当前媒体库、阅读状态和应用托管内容，原始媒体文件不会被修改。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('开始恢复'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBackup(String sourcePath) async {
    setState(() => _checkingBackup = true);
    final command = ref.read(restoreBackupCommandProvider.future);
    final status = ref.read(restoreStatusProvider.notifier)..begin();
    await WidgetsBinding.instance.endOfFrame;
    RestoreBackupResult result;
    try {
      result = await (await command)(sourcePath);
    } on Object {
      result = const RestoreBackupRejected();
    }
    status.complete(result);
  }
}

class _GlobalReaderSettings extends StatelessWidget {
  const _GlobalReaderSettings({
    required this.controller,
    required this.clearMangaCache,
    required this.exportingBackup,
    required this.exportBackup,
    required this.checkingBackup,
    required this.preflightBackup,
  });
  final ReaderSettingsController controller;
  final Future<void> Function() clearMangaCache;
  final bool exportingBackup;
  final Future<void> Function()? exportBackup;
  final bool checkingBackup;
  final Future<void> Function()? preflightBackup;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('默认阅读设置', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('没有单独设置的作品会使用这些值。'),
              const SizedBox(height: 24),
              Text('字号 ${controller.preference.fontSize.round()}'),
              Slider(
                semanticFormatterCallback: (value) => '字号 ${value.round()}',
                min: 12,
                max: 36,
                divisions: 24,
                value: controller.preference.fontSize,
                onChanged: controller.setFontSize,
              ),
              Text('行距 ${controller.preference.lineHeight.toStringAsFixed(1)}'),
              Slider(
                semanticFormatterCallback: (value) =>
                    '行距 ${value.toStringAsFixed(1)}',
                min: 1.2,
                max: 2.4,
                divisions: 12,
                value: controller.preference.lineHeight,
                onChanged: controller.setLineHeight,
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'system', label: Text('跟随系统')),
                    ButtonSegment(value: 'light', label: Text('浅色')),
                    ButtonSegment(value: 'dark', label: Text('深色')),
                    ButtonSegment(value: 'sepia', label: Text('护眼')),
                  ],
                  selected: {controller.preference.themeKey},
                  onSelectionChanged: (values) =>
                      controller.setTheme(values.single),
                ),
              ),
              if (controller.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(controller.errorMessage!),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: controller.resetToInherited,
                  child: const Text('恢复程序默认值'),
                ),
              ),
              const Divider(height: 32),
              Text('数据备份', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ListTile(
                key: const Key('export-backup'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.save_alt_outlined),
                title: Text(exportingBackup ? '正在导出备份' : '导出备份'),
                subtitle: const Text('包含媒体库、阅读状态和应用托管内容，不包含原始媒体文件'),
                onTap: exportBackup,
              ),
              ListTile(
                key: const Key('preflight-backup'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restore_outlined),
                title: Text(checkingBackup ? '正在检查备份' : '检查备份文件'),
                subtitle: const Text('恢复前只读检查完整性和版本兼容性，不会修改当前数据'),
                onTap: preflightBackup,
              ),
              const Divider(height: 32),
              ListTile(
                key: const Key('clear-manga-cache'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cleaning_services_outlined),
                title: const Text('清理漫画页面缓存'),
                subtitle: const Text('不会删除书籍、阅读进度或源文件'),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('清理漫画页面缓存？'),
                      content: const Text('缓存会在下次阅读时自动重新生成。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('取消'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('清理'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) await clearMangaCache();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
