import 'package:logging/logging.dart';

final appLogger = Logger('mirascope');

final class AppLogEvent {
  const AppLogEvent({
    required this.code,
    this.stage,
    this.fileSize,
    this.elapsedMilliseconds,
  }) : assert(fileSize == null || fileSize >= 0),
       assert(elapsedMilliseconds == null || elapsedMilliseconds >= 0);

  final String code;
  final String? stage;
  final int? fileSize;
  final int? elapsedMilliseconds;

  Map<String, Object> toFields() => {
    'code': code,
    'stage': ?stage,
    'fileSize': ?fileSize,
    'elapsedMilliseconds': ?elapsedMilliseconds,
  };

  @override
  String toString() {
    final fields = toFields().entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join(' ');
    return 'app_event $fields';
  }
}

void initializeAppLogging() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.INFO;
}

void logAppWarning(
  String code, {
  String? stage,
  int? fileSize,
  Duration? elapsed,
}) {
  appLogger.warning(
    AppLogEvent(
      code: code,
      stage: stage,
      fileSize: fileSize,
      elapsedMilliseconds: elapsed?.inMilliseconds,
    ),
  );
}

void logAppError(
  String code, {
  String? stage,
  int? fileSize,
  Duration? elapsed,
}) {
  appLogger.severe(
    AppLogEvent(
      code: code,
      stage: stage,
      fileSize: fileSize,
      elapsedMilliseconds: elapsed?.inMilliseconds,
    ),
  );
}
