import 'package:flutter/material.dart';

class NovelReaderPage extends StatelessWidget {
  const NovelReaderPage({required this.mediaItemId, super.key});

  final String mediaItemId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('阅读器')),
      body: Center(child: Text('正在准备媒体：$mediaItemId')),
    );
  }
}
