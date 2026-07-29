import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_error_code.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';

void main() {
  test('AppFailure keeps a stable code and safe message', () {
    const failure = AppFailure(code: 'startup_failed', message: '应用启动失败');

    expect(failure.code, 'startup_failed');
    expect(failure.message, '应用启动失败');
    expect(failure.toString(), 'AppFailure(startup_failed)');
  });

  test('stable error codes are unique and use protocol-safe names', () {
    final values = AppErrorCode.values.map((code) => code.value).toList();

    expect(values.toSet(), hasLength(values.length));
    for (final value in values) {
      expect(value, matches(RegExp(r'^[a-z][a-z0-9_]*$')));
      expect(AppErrorCode.tryParse(value)?.value, value);
    }
    expect(AppErrorCode.tryParse('not_registered'), isNull);
  });

  test('all import errors from the novel specification are registered', () {
    const expected = {
      'file_not_found',
      'file_permission_denied',
      'empty_file',
      'encoding_unknown',
      'decode_failed',
      'no_readable_content',
      'import_duplicate',
      'parse_failed',
      'storage_failed',
      'source_changed',
    };

    expect(
      AppErrorCode.values.map((code) => code.value).toSet(),
      containsAll(expected),
    );
  });

  test('known failure is preserved and unknown details are discarded', () {
    const privatePath = r'C:\Users\private\secret.txt';
    const known = AppFailure(code: 'empty_file', message: '文件为空');

    expect(
      mapToAppFailure(known, fallback: AppErrorCode.storageFailed),
      same(known),
    );

    final mapped = mapToAppFailure(
      StateError(privatePath),
      fallback: AppErrorCode.storageFailed,
    );
    expect(mapped.code, 'storage_failed');
    expect(mapped.toString(), isNot(contains(privatePath)));
    expect(mapped.message, isNot(contains(privatePath)));
    expect(mapped.recovery, isNot(contains(privatePath)));
  });
}
