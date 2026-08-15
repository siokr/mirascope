import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/logging/app_logger.dart';
import '../../library/domain/library_entry.dart';
import '../../library/domain/media_item.dart';
import '../../manga/domain/manga_page.dart';
import '../../novel/domain/content_unit.dart';
import '../domain/derived_manga_store.dart';
import '../domain/import_record.dart';
import '../domain/import_repository.dart';
import '../domain/manga_manifest.dart';
import '../domain/manga_source.dart';
import '../domain/successful_import.dart';
import 'import_txt.dart' show ImportClock;

typedef MangaManifestLoader =
    Future<MangaManifest> Function(MangaSourceCandidate candidate);
typedef MangaPageBytesLoader =
    Future<Uint8List> Function(
      MangaSourceCandidate candidate,
      String sourcePath,
    );

sealed class MangaImportResult {
  const MangaImportResult();
}

final class MangaImportSucceeded extends MangaImportResult {
  const MangaImportSucceeded(this.mediaItemId);
  final String mediaItemId;
}

final class MangaImportDuplicate extends MangaImportResult {
  const MangaImportDuplicate(this.mediaItemId);
  final String mediaItemId;
}

final class MangaImportFailed extends MangaImportResult {
  const MangaImportFailed(this.failure);
  final AppFailure failure;
}

final class ImportManga {
  const ImportManga({
    required this.loadManifest,
    required this.loadPageBytes,
    required this.importRepository,
    required this.derivedMangaStore,
    required this.idGenerator,
    required this.clock,
  });

  final MangaManifestLoader loadManifest;
  final MangaPageBytesLoader loadPageBytes;
  final ImportRepository importRepository;
  final DerivedMangaStore derivedMangaStore;
  final IdGenerator idGenerator;
  final ImportClock clock;

  Future<MangaImportResult> call(MangaSourceCandidate candidate) async {
    final duplicate = await importRepository.findCompletedByFingerprint(
      candidate.fingerprint,
    );
    if (duplicate != null) return MangaImportDuplicate(duplicate.mediaItemId!);

    StagedDerivedManga? staged;
    var promoted = false;
    try {
      final manifest = await loadManifest(candidate);
      final coverPage = manifest.chapters.first.pages.first;
      final coverBytes = await loadPageBytes(candidate, coverPage.sourcePath);
      final mediaId = idGenerator.newId();
      final now = clock().toUtc();
      staged = await derivedMangaStore.stage(
        mediaItemId: mediaId,
        manifest: manifest,
        coverBytes: coverBytes,
      );

      final units = <ContentUnit>[];
      final pages = <MangaPage>[];
      for (
        var chapterIndex = 0;
        chapterIndex < manifest.chapters.length;
        chapterIndex++
      ) {
        final chapter = manifest.chapters[chapterIndex];
        final unitId = idGenerator.newId();
        final chapterHash = sha256.convert(
          utf8.encode(chapter.pages.map((page) => page.contentHash).join('\n')),
        );
        units.add(
          ContentUnit(
            id: unitId,
            mediaItemId: mediaId,
            unitType: ContentUnitType.chapter,
            title: chapter.title,
            orderIndex: chapterIndex,
            contentRef: 'manga/$mediaId/chapters/$chapterIndex',
            sourceLocator: 'manga-chapter-v1:${chapter.title}',
            contentHash: chapterHash.toString(),
          ),
        );
        for (var pageIndex = 0; pageIndex < chapter.pages.length; pageIndex++) {
          final page = chapter.pages[pageIndex];
          pages.add(
            MangaPage(
              id: idGenerator.newId(),
              contentUnitId: unitId,
              orderIndex: pageIndex,
              contentRef: 'source:${page.sourcePath}',
              sourceLocator: page.sourcePath,
              contentHash: page.contentHash,
              imageType: page.imageType,
              byteLength: page.byteLength,
              pixelWidth: page.pixelWidth,
              pixelHeight: page.pixelHeight,
            ),
          );
        }
      }

      final successful = SuccessfulImport(
        mediaItem: MediaItem(
          id: mediaId,
          mediaType: MediaType.manga,
          title: _sourceTitle(candidate.path),
          coverRef: staged.coverRef,
          createdAt: now,
          updatedAt: now,
        ),
        libraryEntry: LibraryEntry(
          id: idGenerator.newId(),
          mediaItemId: mediaId,
          favorite: false,
          addedAt: now,
        ),
        contentUnits: units,
        mangaPages: pages,
        importRecord: ImportRecord(
          id: idGenerator.newId(),
          mediaItemId: mediaId,
          sourcePath: candidate.path,
          sourceKind: candidate.kind == MangaSourceKind.archive
              ? ImportSourceKind.mangaArchive
              : ImportSourceKind.mangaDirectory,
          fileSize: candidate.fileSize,
          modifiedAt: candidate.modifiedAt,
          fingerprint: candidate.fingerprint,
          status: ImportStatus.completed,
          createdAt: now,
        ),
      );
      await importRepository.commitSuccessfulImport(
        successful,
        beforeCommit: () async {
          await derivedMangaStore.promote(staged!);
          promoted = true;
        },
      );
      return MangaImportSucceeded(mediaId);
    } on Object catch (error) {
      final failure = mapToAppFailure(
        error,
        fallback: AppErrorCode.storageFailed,
      );
      if (staged != null) {
        await _ignoreCleanup(
          promoted
              ? () => derivedMangaStore.removeCommitted(staged!)
              : () => derivedMangaStore.discard(staged!),
        );
      }
      await _recordFailure(candidate, failure.code);
      logAppWarning(failure.code, stage: 'import_manga');
      return MangaImportFailed(failure);
    }
  }

  Future<void> _recordFailure(
    MangaSourceCandidate candidate,
    String code,
  ) async {
    try {
      await importRepository.recordFailure(
        ImportRecord(
          id: idGenerator.newId(),
          sourcePath: candidate.path,
          sourceKind: candidate.kind == MangaSourceKind.archive
              ? ImportSourceKind.mangaArchive
              : ImportSourceKind.mangaDirectory,
          fileSize: candidate.fileSize,
          modifiedAt: candidate.modifiedAt,
          fingerprint: candidate.fingerprint,
          status: ImportStatus.failed,
          errorCode: code,
          createdAt: clock().toUtc(),
        ),
      );
    } on Object {
      // Preserve the stable import failure when failure recording also fails.
    }
  }

  Future<void> _ignoreCleanup(Future<void> Function() cleanup) async {
    try {
      await cleanup();
    } on Object {
      // Best-effort compensation must not replace the original failure.
    }
  }

  String _sourceTitle(String path) {
    final normalized = path
        .replaceAll('\\', '/')
        .replaceAll(RegExp(r'/+$'), '');
    final name = normalized.substring(normalized.lastIndexOf('/') + 1);
    return name.replaceFirst(RegExp(r'\.(zip|cbz)$', caseSensitive: false), '');
  }
}
