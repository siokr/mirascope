import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/ids/id_generator.dart';

void main() {
  test('UuidIdGenerator creates distinct UUID values', () {
    final generator = UuidIdGenerator();
    final first = generator.newId();
    final second = generator.newId();

    expect(first, isNot(second));
    expect(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(first),
      isTrue,
    );
  });
}
