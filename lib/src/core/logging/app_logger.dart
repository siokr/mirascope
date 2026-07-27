import 'package:logging/logging.dart';

final appLogger = Logger('mirascope');

void initializeAppLogging() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.INFO;
}
