import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/library/application/library_providers.dart';
import 'package:mirascope/src/features/novel/domain/content_unit.dart';
import 'package:mirascope/src/features/novel/domain/novel_details.dart';
import 'package:mirascope/src/features/importing/domain/import_record.dart';
import 'package:mirascope/src/features/novel/domain/novel_details_repository.dart';
import 'package:mirascope/src/features/novel/presentation/novel_details_page.dart';

import '../../library/library_test_support.dart';

void main() {
  testWidgets('shows title, ordered directory and opens reader', (
    tester,
  ) async {
    var opened = false;
    String? openedChapter;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelDetailsRepositoryProvider.overrideWithValue(
            _Repository(_details(sourceAvailable: true)),
          ),
        ],
        child: MaterialApp(
          home: NovelDetailsPage(
            mediaItemId: 'media-1',
            onStartReading: (chapterId) {
              opened = true;
              openedChapter = chapterId;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Book'), findsOneWidget);
    expect(find.text('副标题'), findsOneWidget);
    expect(find.text('作者：作者名'), findsOneWidget);
    expect(find.text('作品简介'), findsOneWidget);
    expect(find.text('共 2 章'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    await tester.tap(find.text('开始阅读'));
    expect(opened, isTrue);
    expect(openedChapter, isNull);

    opened = false;
    await tester.tap(find.text('Second'));
    expect(opened, isTrue);
    expect(openedChapter, 'unit-2');
  });

  testWidgets('missing source preserves directory and offers relocation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var relocated = false;
    var opened = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelDetailsRepositoryProvider.overrideWithValue(
            _Repository(_details(sourceAvailable: false)),
          ),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: NovelDetailsPage(
            mediaItemId: 'media-1',
            onStartReading: (_) => opened = true,
            onRelocateSource: () => relocated = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('源文件已移动或不可用，请重新定位。'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
    expect(find.text('开始阅读'), findsOneWidget);
    await tester.tap(find.text('开始阅读'));
    expect(opened, isTrue);
    await tester.tap(find.text('重新定位源文件'));
    expect(relocated, isTrue);
  });

  testWidgets('edits local metadata from the details page', (tester) async {
    final library = FakeMediaLibraryRepository();
    addTearDown(library.close);
    final updatedAt = DateTime.utc(2026, 8, 22, 12);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelDetailsRepositoryProvider.overrideWithValue(
            _Repository(_details(sourceAvailable: true)),
          ),
          mediaLibraryRepositoryProvider.overrideWithValue(library),
          libraryClockProvider.overrideWithValue(() => updatedAt),
        ],
        child: MaterialApp(
          home: NovelDetailsPage(
            mediaItemId: 'media-1',
            onStartReading: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('edit-media-metadata')));
    await tester.pumpAndSettle();
    expect(find.text('编辑作品信息'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Book'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('metadata-title-field')),
      '  新书名  ',
    );
    await tester.enterText(
      find.byKey(const Key('metadata-subtitle-field')),
      '副标题',
    );
    await tester.enterText(
      find.byKey(const Key('metadata-creator-field')),
      '作者',
    );
    await tester.enterText(
      find.byKey(const Key('metadata-description-field')),
      '简介',
    );
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(library.metadataUpdates, hasLength(1));
    final update = library.metadataUpdates.single;
    expect(update.mediaItemId, 'media-1');
    expect(update.title, '  新书名  ');
    expect(update.subtitle, '副标题');
    expect(update.creator, '作者');
    expect(update.description, '简介');
    expect(update.updatedAt, updatedAt);
    expect(find.text('作品信息已保存'), findsOneWidget);
  });

  testWidgets('keeps metadata editor open when title is blank', (tester) async {
    final library = FakeMediaLibraryRepository();
    addTearDown(library.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelDetailsRepositoryProvider.overrideWithValue(
            _Repository(_details(sourceAvailable: true)),
          ),
          mediaLibraryRepositoryProvider.overrideWithValue(library),
        ],
        child: MaterialApp(
          home: NovelDetailsPage(
            mediaItemId: 'media-1',
            onStartReading: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('edit-media-metadata')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('metadata-title-field')),
      '   ',
    );
    await tester.tap(find.text('保存'));
    await tester.pump();

    expect(find.text('请输入书名'), findsOneWidget);
    expect(find.text('编辑作品信息'), findsOneWidget);
    expect(library.metadataUpdates, isEmpty);
  });
}

NovelDetails _details({required bool sourceAvailable}) {
  final now = DateTime.utc(2026, 7, 29);
  return NovelDetails(
    mediaItem: MediaItem(
      id: 'media-1',
      mediaType: MediaType.novel,
      title: 'Book',
      subtitle: '副标题',
      creator: '作者名',
      description: '作品简介',
      createdAt: now,
      updatedAt: now,
    ),
    chapters: [_chapter('unit-1', 'First', 0), _chapter('unit-2', 'Second', 1)],
    sourceAvailable: sourceAvailable,
    sourceKind: ImportSourceKind.txtFile,
  );
}

ContentUnit _chapter(String id, String title, int order) => ContentUnit(
  id: id,
  mediaItemId: 'media-1',
  unitType: ContentUnitType.chapter,
  title: title,
  orderIndex: order,
  contentRef: 'content/book.txt',
  sourceLocator: 'txt-v1:0:0:1',
  contentHash: 'hash-$id',
);

final class _Repository implements NovelDetailsRepository {
  const _Repository(this.details);
  final NovelDetails? details;

  @override
  Future<NovelDetails?> findDetails(String mediaItemId) async => details;
}
