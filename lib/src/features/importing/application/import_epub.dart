import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/logging/app_logger.dart';
import '../../library/domain/library_entry.dart';
import '../../library/domain/media_item.dart';
import '../../novel/domain/content_unit.dart';
import '../domain/derived_epub_store.dart';
import '../domain/epub_container.dart';
import '../domain/epub_semantic_content.dart';
import '../domain/epub_source_candidate.dart';
import '../domain/import_record.dart';
import '../domain/import_repository.dart';
import '../domain/parsed_epub.dart';
import '../domain/successful_import.dart';
import 'import_txt.dart';

typedef EpubContainerFactory = Future<EpubContainer> Function(String path);
typedef EpubPackageParser =
    Future<ParsedEpub> Function(EpubContainer container);
typedef EpubContentNormalizer =
    Future<List<EpubSemanticChapter>> Function(
      EpubContainer container,
      ParsedEpub book,
    );

sealed class EpubImportResult {
  const EpubImportResult();
}

final class EpubImportSucceeded extends EpubImportResult {
  const EpubImportSucceeded(this.mediaItemId);
  final String mediaItemId;
}

final class EpubImportDuplicate extends EpubImportResult {
  const EpubImportDuplicate(this.mediaItemId);
  final String mediaItemId;
}

final class EpubImportFailed extends EpubImportResult {
  const EpubImportFailed(this.failure);
  final AppFailure failure;
}

final class ImportEpub {
  const ImportEpub({
    required this.openContainer,
    required this.parsePackage,
    required this.normalizeContent,
    required this.importRepository,
    required this.derivedEpubStore,
    required this.idGenerator,
    required this.clock,
  });

  final EpubContainerFactory openContainer;
  final EpubPackageParser parsePackage;
  final EpubContentNormalizer normalizeContent;
  final ImportRepository importRepository;
  final DerivedEpubStore derivedEpubStore;
  final IdGenerator idGenerator;
  final ImportClock clock;

  Future<EpubImportResult> call(EpubSourceCandidate candidate) async {
    final duplicate = await importRepository.findCompletedByFingerprint(
      candidate.fingerprint,
    );
    if (duplicate != null) {
      return EpubImportDuplicate(duplicate.mediaItemId!);
    }

    EpubContainer? container;
    StagedDerivedEpub? staged;
    var promoted = false;
    try {
      container = await openContainer(candidate.path);
      final book = await parsePackage(container);
      final chapters = await normalizeContent(container, book);
      if (chapters.isEmpty) {
        throw AppFailure.fromCode(AppErrorCode.epubSpineEmpty);
      }

      final now = clock().toUtc();
      final mediaId = idGenerator.newId();
      staged = await derivedEpubStore.stage(
        mediaItemId: mediaId,
        book: book,
        chapters: chapters,
        container: container,
      );
      final contentUnits = <ContentUnit>[
        for (var index = 0; index < chapters.length; index++)
          ContentUnit(
            id: idGenerator.newId(),
            mediaItemId: mediaId,
            unitType: ContentUnitType.chapter,
            title: chapters[index].title,
            orderIndex: index,
            contentRef: staged.chapters[index].contentRef,
            sourceLocator: 'epub-v1:${chapters[index].manifestId}',
            contentHash: staged.chapters[index].contentHash,
          ),
      ];
      final import = SuccessfulImport(
        mediaItem: MediaItem(
          id: mediaId,
          mediaType: MediaType.novel,
          title: book.title.trim(),
          creator: book.authors.isEmpty ? null : book.authors.join('、'),
          createdAt: now,
          updatedAt: now,
        ),
        libraryEntry: LibraryEntry(
          id: idGenerator.newId(),
          mediaItemId: mediaId,
          favorite: false,
          addedAt: now,
        ),
        contentUnits: contentUnits,
        importRecord: ImportRecord(
          id: idGenerator.newId(),
          mediaItemId: mediaId,
          sourcePath: candidate.path,
          sourceKind: ImportSourceKind.epubFile,
          fileSize: candidate.fileSize,
          modifiedAt: candidate.modifiedAt,
          fingerprint: candidate.fingerprint,
          status: ImportStatus.completed,
          createdAt: now,
        ),
      );

      await importRepository.commitSuccessfulImport(
        import,
        beforeCommit: () async {
          await derivedEpubStore.promote(staged!);
          promoted = true;
        },
      );
      return EpubImportSucceeded(mediaId);
    } on Object catch (error) {
      final failure = mapToAppFailure(
        error,
        fallback: AppErrorCode.storageFailed,
      );
      if (staged != null) {
        if (promoted) {
          await _ignoreCleanup(() => derivedEpubStore.removeCommitted(staged!));
        } else {
          await _ignoreCleanup(() => derivedEpubStore.discard(staged!));
        }
      }
      await _recordFailure(candidate, failure.code);
      logAppWarning(failure.code, stage: 'import_epub');
      return EpubImportFailed(failure);
    } finally {
      if (container != null) {
        await _ignoreCleanup(container.close);
      }
    }
  }

  Future<void> _recordFailure(
    EpubSourceCandidate candidate,
    String errorCode,
  ) async {
    try {
      await importRepository.recordFailure(
        ImportRecord(
          id: idGenerator.newId(),
          sourcePath: candidate.path,
          sourceKind: ImportSourceKind.epubFile,
          fileSize: candidate.fileSize,
          modifiedAt: candidate.modifiedAt,
          fingerprint: candidate.fingerprint,
          status: ImportStatus.failed,
          errorCode: errorCode,
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
      // Best-effort compensation must not expose platform details.
    }
  }
}
