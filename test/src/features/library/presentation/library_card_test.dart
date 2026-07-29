import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/library/domain/library_entry.dart';
import 'package:mirascope/src/features/library/domain/library_item.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/library/presentation/widgets/library_card.dart';

void main() {
  testWidgets('card shows cover metadata and accessible actions', (
    tester,
  ) async {
    final item = _item(
      id: 'book-1',
      title: '长夜书简',
      creator: '林遥',
      lastOpenedAt: DateTime.utc(2026, 7, 29),
    );
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: LibraryCard(
              item: item,
              archived: false,
              busy: false,
              onOpen: () => opened = true,
              onArchive: () {},
              onRestore: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('长夜书简'), findsOneWidget);
    expect(find.text('林遥'), findsOneWidget);
    expect(find.text('最近阅读 2026/07/29'), findsOneWidget);
    expect(find.text('长'), findsOneWidget);
    expect(find.bySemanticsLabel('打开《长夜书简》'), findsOneWidget);
    final menu = tester.widget<PopupMenuButton<LibraryCardAction>>(
      find.byKey(const Key('library-menu-book-1')),
    );
    expect(menu.tooltip, '更多操作');

    await tester.tap(find.bySemanticsLabel('打开《长夜书简》'));
    expect(opened, isTrue);
  });

  testWidgets('card uses subtitle fallback and stable placeholder color', (
    tester,
  ) async {
    final first = _item(id: 'same-id', title: '第一本', subtitle: '副标题');
    final second = _item(id: 'same-id', title: '第二本');

    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            SizedBox(width: 220, child: _card(first)),
            SizedBox(width: 220, child: _card(second)),
          ],
        ),
      ),
    );

    expect(find.text('副标题'), findsOneWidget);
    expect(find.text('TXT 小说'), findsOneWidget);
    final covers = tester
        .widgetList<ColoredBox>(
          find.byKey(const ValueKey('library-cover-same-id')),
        )
        .toList();
    expect(covers, hasLength(2));
    expect(covers.first.color, covers.last.color);
  });

  testWidgets('busy card blocks open and menu actions without overflowing', (
    tester,
  ) async {
    final item = _item(
      id: 'busy',
      title: '一本标题特别特别长但依然不应该破坏媒体卡片布局的小说',
      creator: '一位名字同样非常非常长的作者',
    );
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 380,
            child: LibraryCard(
              item: item,
              archived: false,
              busy: true,
              onOpen: () => opened = true,
              onArchive: () {},
              onRestore: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('library-card-busy')));
    expect(opened, isFalse);
    expect(tester.takeException(), isNull);
    expect(
      tester
          .widget<PopupMenuButton<LibraryCardAction>>(
            find.byKey(const Key('library-menu-busy')),
          )
          .enabled,
      isFalse,
    );
  });

  testWidgets('archived card exposes restore instead of archive', (
    tester,
  ) async {
    final item = _item(id: 'archived', title: '旧书');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            child: LibraryCard(
              item: item,
              archived: true,
              busy: false,
              onOpen: () {},
              onArchive: () {},
              onRestore: () {},
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('library-menu-archived')));
    await tester.pumpAndSettle();

    expect(find.text('恢复到媒体库'), findsOneWidget);
    expect(find.text('移入归档'), findsNothing);
  });
}

LibraryCard _card(LibraryItem item) {
  return LibraryCard(
    item: item,
    archived: false,
    busy: false,
    onOpen: () {},
    onArchive: () {},
    onRestore: () {},
  );
}

LibraryItem _item({
  required String id,
  required String title,
  String? subtitle,
  String? creator,
  DateTime? lastOpenedAt,
}) {
  final now = DateTime.utc(2026, 7, 29);
  return LibraryItem(
    mediaItem: MediaItem(
      id: id,
      mediaType: MediaType.novel,
      title: title,
      subtitle: subtitle,
      creator: creator,
      createdAt: now,
      updatedAt: now,
    ),
    libraryEntry: LibraryEntry(
      id: 'entry-$id',
      mediaItemId: id,
      favorite: false,
      addedAt: now,
      lastOpenedAt: lastOpenedAt,
    ),
  );
}
