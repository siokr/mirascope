import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';

void main() {
  test('AppFailure keeps a stable code and safe message', () {
    const failure = AppFailure(code: 'startup_failed', message: '应用启动失败');

    expect(failure.code, 'startup_failed');
    expect(failure.message, '应用启动失败');
    expect(failure.toString(), 'AppFailure(startup_failed)');
  });
}
