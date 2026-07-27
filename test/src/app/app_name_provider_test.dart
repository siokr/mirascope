import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/app/app_name_provider.dart';

void main() {
  test('appNameProvider exposes the product name', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(appNameProvider), 'mirascope');
  });
}
