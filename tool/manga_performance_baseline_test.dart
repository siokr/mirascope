import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/importing/data/dart_io_manga_manifest_scanner.dart';
import 'package:mirascope/src/features/importing/data/flutter_manga_image_decoder.dart';
import 'package:mirascope/src/features/importing/domain/manga_manifest.dart';
import 'package:mirascope/src/features/importing/domain/manga_source.dart';
import 'package:mirascope/src/features/manga/application/manga_page_loader.dart';
import 'package:mirascope/src/features/manga/data/dart_io_manga_page_cache.dart';
import 'package:mirascope/src/features/manga/domain/manga_page.dart';
import 'package:mirascope/src/features/manga/domain/manga_reader_book.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'records the local manga pipeline baseline',
    () async {
      final source = Platform.environment['MIRASCOPE_MANGA_BENCHMARK_SOURCE'];
      if (source == null || source.isEmpty) {
        fail('Set MIRASCOPE_MANGA_BENCHMARK_SOURCE to a directory or ZIP/CBZ.');
      }
      final kind =
          Platform.environment['MIRASCOPE_MANGA_BENCHMARK_KIND'] == 'directory'
          ? MangaSourceKind.directory
          : MangaSourceKind.archive;
      final selection = MangaSourceSelection(path: source, kind: kind);
      final scanner = DartIoMangaManifestScanner(
        const FlutterMangaImageDecoder(),
      );
      final results = <Map<String, Object>>[];

      for (var iteration = 0; iteration < 4; iteration++) {
        final cacheRoot = await Directory.systemTemp.createTemp(
          'mirascope_manga_benchmark_cache_',
        );
        try {
          final rssBefore = ProcessInfo.currentRss;
          final scanWatch = Stopwatch()..start();
          final manifest = await scanner.scan(selection);
          scanWatch.stop();
          final pages = <MangaPage>[
            for (final chapter in manifest.chapters)
              for (var index = 0; index < chapter.pages.length; index++)
                _page(chapter.title, index, chapter.pages[index]),
          ];
          final loader = MangaPageLoader(
            mediaItemId: 'benchmark-media',
            repository: _Repository(scanner, selection),
            cache: DartIoMangaPageCache(cacheRoot),
            preloadRadius: 0,
          );
          final firstWatch = Stopwatch()..start();
          await loader.load(pages.first);
          firstWatch.stop();
          final sequentialCount = min(50, pages.length);
          final sequentialWatch = Stopwatch()..start();
          for (var index = 0; index < sequentialCount; index++) {
            await loader.load(pages[index]);
          }
          sequentialWatch.stop();
          var cacheBytes = 0;
          await for (final entity in cacheRoot.list()) {
            if (entity is File) cacheBytes += await entity.length();
          }
          results.add({
            'iteration': iteration,
            'warmup': iteration == 0,
            'chapters': manifest.chapters.length,
            'pages': manifest.pageCount,
            'sourceBytes': pages.fold<int>(
              0,
              (total, page) => total + page.byteLength,
            ),
            'scanMs': scanWatch.elapsedMicroseconds / 1000,
            'firstPageMs': firstWatch.elapsedMicroseconds / 1000,
            'sequentialPages': sequentialCount,
            'sequentialMs': sequentialWatch.elapsedMicroseconds / 1000,
            'cacheBytes': cacheBytes,
            'rssBeforeBytes': rssBefore,
            'rssAfterBytes': ProcessInfo.currentRss,
          });
        } finally {
          if (await cacheRoot.exists()) {
            await cacheRoot.delete(recursive: true);
          }
        }
      }
      // A stable marker lets the invoking script extract structured data without
      // depending on flutter_test's reporter formatting.
      stdout.writeln('MIRASCOPE_MANGA_BASELINE=${jsonEncode(results)}');
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

MangaPage _page(String chapter, int index, MangaManifestPage page) => MangaPage(
  id: '$chapter:$index',
  contentUnitId: chapter,
  orderIndex: index,
  contentRef: page.sourcePath,
  sourceLocator: page.sourcePath,
  contentHash: page.contentHash,
  imageType: page.imageType,
  byteLength: page.byteLength,
  pixelWidth: page.pixelWidth,
  pixelHeight: page.pixelHeight,
);

final class _Repository implements MangaReaderRepository {
  const _Repository(this.scanner, this.selection);
  final DartIoMangaManifestScanner scanner;
  final MangaSourceSelection selection;

  @override
  Future<MangaReaderBook?> loadBook(String mediaItemId) async => null;

  @override
  Future<Uint8List> readPage(String mediaItemId, MangaPage page) =>
      scanner.readPage(selection, page.sourceLocator);
}
