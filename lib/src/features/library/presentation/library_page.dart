import 'package:flutter/material.dart';
import 'package:mirascope/src/shared/widgets/empty_state.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({required this.onOpenSettings, super.key});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('媒体库'),
        actions: [
          IconButton(
            key: const Key('open-settings'),
            onPressed: onOpenSettings,
            tooltip: '设置',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: const EmptyState(
        icon: Icons.menu_book_outlined,
        title: '媒体库还是空的',
        message: '导入一本 TXT 小说，开始建立你的本地书架。',
      ),
    );
  }
}
