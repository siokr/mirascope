import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mirascope/src/app/routing/app_router.dart';
import 'package:mirascope/src/app/theme/app_theme.dart';

class MirascopeApp extends StatefulWidget {
  const MirascopeApp({this.router, super.key});

  final GoRouter? router;

  @override
  State<MirascopeApp> createState() => _MirascopeAppState();
}

class _MirascopeAppState extends State<MirascopeApp> {
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
    return MaterialApp.router(
      title: 'mirascope',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
