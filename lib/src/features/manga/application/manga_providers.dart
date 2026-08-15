import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../core/database/database_providers.dart';
import '../domain/manga_details.dart';
import '../data/dart_io_manga_reader_repository.dart';
import '../domain/manga_reader_book.dart';
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

final mangaReaderBookProvider = FutureProvider.autoDispose
    .family<MangaReaderBook?, String>(
      (ref, mediaItemId) =>
          ref.watch(mangaReaderRepositoryProvider).loadBook(mediaItemId),
    );
