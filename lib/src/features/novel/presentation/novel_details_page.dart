import 'package:flutter/material.dart';

class NovelDetailsPage extends StatelessWidget {
  const NovelDetailsPage({required this.mediaItemId, super.key});

  final String mediaItemId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('小说详情')),
      body: Center(child: Text('媒体 ID：$mediaItemId')),
    );
  }
}
