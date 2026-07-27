import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/app/app.dart';

void main() {
  testWidgets('shows the empty library on startup', (tester) async {
    await tester.pumpWidget(const MirascopeApp());
    await tester.pumpAndSettle();

    expect(find.text('媒体库还是空的'), findsOneWidget);
    expect(find.text('导入一本 TXT 小说，开始建立你的本地书架。'), findsOneWidget);
  });
}
