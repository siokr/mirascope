import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirascope/src/app/app.dart';
import 'package:mirascope/src/app/bootstrap/startup_error_app.dart';
import 'package:mirascope/src/core/logging/app_logger.dart';

typedef AppInitializer = Future<void> Function();

Future<Widget> buildRootWidget({AppInitializer? initialize}) async {
  initializeAppLogging();

  try {
    await (initialize ?? _initializeFoundation)();
    return const ProviderScope(child: MirascopeApp());
  } on Object catch (error, stackTrace) {
    appLogger.severe('startup_failed', error, stackTrace);
    return const StartupErrorApp(code: 'startup_failed');
  }
}

Future<void> _initializeFoundation() async {}
