import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:mirascope/src/core/logging/app_logger.dart';

void main() {
  setUp(initializeAppLogging);

  test('structured event exposes only approved fields', () {
    const event = AppLogEvent(
      code: 'file_not_found',
      stage: 'validate_source',
      fileSize: 42,
      elapsedMilliseconds: 7,
    );

    expect(event.toFields(), {
      'code': 'file_not_found',
      'stage': 'validate_source',
      'fileSize': 42,
      'elapsedMilliseconds': 7,
    });
    expect(
      event.toString(),
      'app_event code=file_not_found stage=validate_source '
      'fileSize=42 elapsedMilliseconds=7',
    );
  });

  test('safe logger never attaches an error or stack trace', () async {
    const privatePath = r'C:\Users\private\secret.txt';
    final records = <LogRecord>[];
    final subscription = Logger.root.onRecord.listen(records.add);
    addTearDown(subscription.cancel);

    logAppWarning(
      'file_not_found',
      stage: 'validate_source',
      fileSize: 42,
      elapsed: const Duration(milliseconds: 7),
    );
    await Future<void>.delayed(Duration.zero);

    expect(records, hasLength(1));
    expect(
      records.single.message,
      'app_event code=file_not_found stage=validate_source '
      'fileSize=42 elapsedMilliseconds=7',
    );
    expect(records.single.error, isNull);
    expect(records.single.stackTrace, isNull);
    expect(records.single.toString(), isNot(contains(privatePath)));
  });

  test('event rejects negative numeric metadata', () {
    expect(
      () => AppLogEvent(code: 'empty_file', fileSize: -1),
      throwsAssertionError,
    );
    expect(
      () => AppLogEvent(code: 'empty_file', elapsedMilliseconds: -1),
      throwsAssertionError,
    );
  });
}
