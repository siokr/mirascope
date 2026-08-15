import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../core/database/database_providers.dart';
import '../domain/manga_details.dart';
import '../data/dart_io_manga_reader_repository.dart';
import '../domain/manga_reader_book.dart';
import 'manga_reading_state.dart';
import 'manga_page_loader.dart';
import '../data/dart_io_manga_page_cache.dart';
import '../domain/manga_page_cache.dart';
import '../../../core/ids/id_generator.dart';
import '../../importing/application/importing_providers.dart';

final mangaDetailsProvider = FutureProvider.autoDispose
    .family<MangaDetails?, String>(
      (ref, mediaItemId) =>
          ref.watch(mangaDetailsRepositoryProvider).findDetails(mediaItemId),
    );

final mangaCoverFileProvider = FutureProvider.autoDispose.family<File?, String>((
  ref,
  coverRef,
) async {
  final match = RegExp(
    r'^manga/([A-Za-z0-9_-]+)/cover\.png$',
  ).firstMatch(coverRef);
  if (match == null) return null;
  final support = await getApplicationSupportDirectory();
  final file = File(
    '${support.path}${Platform.pathSeparator}derived_manga'
    '${Platform.pathSeparator}content${Platform.pathSeparator}${match.group(1)}'
    '${Platform.pathSeparator}cover.png',
  );
  return await file.exists() ? file : null;
});

final mangaReaderRepositoryProvider = Provider<MangaReaderRepository>((ref) {
  return DartIoMangaReaderRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(mangaManifestScannerProvider),
  );
});

final mangaPageCacheProvider = FutureProvider<MangaPageCache>((ref) async {
  final support = await getApplicationSupportDirectory();
  return DartIoMangaPageCache(
    Directory(
      '${support.path}${Platform.pathSeparator}derived_manga${Platform.pathSeparator}cache',
    ),
  );
});

final mangaPageLoaderProvider = FutureProvider.autoDispose
    .family<MangaPageLoader, String>((ref, mediaItemId) async {
      return MangaPageLoader(
        mediaItemId: mediaItemId,
        repository: ref.watch(mangaReaderRepositoryProvider),
        cache: await ref.watch(mangaPageCacheProvider.future),
      );
    });

final mangaReaderBookProvider = FutureProvider.autoDispose
    .family<MangaReaderBook?, String>(
      (ref, mediaItemId) =>
          ref.watch(mangaReaderRepositoryProvider).loadBook(mediaItemId),
    );

typedef MangaReadingRequest = ({
  String mediaItemId,
  String? initialContentUnitId,
});

final mangaReadingStateProvider = FutureProvider.autoDispose
    .family<MangaReadingState, MangaReadingRequest>((ref, request) async {
      final book = await ref.watch(
        mangaReaderBookProvider(request.mediaItemId).future,
      );
      if (book == null || book.pages.isEmpty) {
        throw StateError('manga_reader_empty');
      }
      final state = MangaReadingState(
        mediaItemId: request.mediaItemId,
        book: book,
        progressRepository: ref.watch(readingProgressRepositoryProvider),
        preferenceRepository: ref.watch(
          mangaReaderPreferenceRepositoryProvider,
        ),
        idGenerator: const UuidIdGenerator(),
        clock: () => DateTime.now().toUtc(),
        initialContentUnitId: request.initialContentUnitId,
      );
      await state.initialize();
      return state;
    });
