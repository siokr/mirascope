import 'package:flutter/material.dart';

import '../../../../shared/widgets/empty_state.dart';

class LibraryErrorState extends StatelessWidget {
  const LibraryErrorState({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.sync_problem_outlined,
      title: '暂时无法读取媒体库',
      message: '内容没有丢失，请稍后重试。',
      action: FilledButton.tonal(onPressed: onRetry, child: const Text('重试')),
    );
  }
}
