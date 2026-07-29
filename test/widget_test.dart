import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/app/app.dart';
import 'package:mirascope/src/core/database/database_providers.dart';

import 'src/features/library/library_test_support.dart';

void main() {
  testWidgets('shows the empty library on startup', (tester) async {
    final repository = FakeMediaLibraryRepository();
    addTearDown(() {
      repository.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaLibraryRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MirascopeApp(),
      ),
    );
    repository.activeController.add([]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('媒体库还是空的'), findsOneWidget);
    expect(find.text('导入 TXT 小说后，它会出现在这里。'), findsOneWidget);
  });
}
