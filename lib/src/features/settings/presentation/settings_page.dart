import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/reader_settings_controller.dart';
import '../application/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        data: (value) => _GlobalReaderSettings(controller: value),
      ),
    );
  }
}

class _GlobalReaderSettings extends StatelessWidget {
  const _GlobalReaderSettings({required this.controller});
  final ReaderSettingsController controller;

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
            ],
          ),
        ),
      ),
    );
  }
}
