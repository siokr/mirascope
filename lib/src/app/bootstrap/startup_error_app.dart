import 'package:flutter/material.dart';
import 'package:mirascope/src/app/theme/app_theme.dart';

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mirascope',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 56),
                  const SizedBox(height: 20),
                  Text(
                    '应用启动失败',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '初始化未完成，请重启应用后重试；若问题持续，请记录错误代码。',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(code),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
