import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/logging/app_logger.dart';
import '../../library/domain/library_entry.dart';
import '../../library/domain/media_item.dart';
import '../../novel/domain/content_unit.dart';
import '../domain/decoded_txt.dart';
import '../domain/derived_txt_store.dart';
import '../domain/import_record.dart';
import '../domain/import_repository.dart';
import '../domain/successful_import.dart';
import '../domain/txt_encoding.dart';
import '../domain/txt_source_candidate.dart';
import 'decode_txt_source.dart';
import 'txt_chapter_detector.dart';

typedef ImportClock = DateTime Function();

sealed class TxtImportResult {
  const TxtImportResult();
}

final class TxtImportSucceeded extends TxtImportResult {
  const TxtImportSucceeded(this.mediaItemId);
  final String mediaItemId;
}

final class TxtImportDuplicate extends TxtImportResult {
  const TxtImportDuplicate(this.mediaItemId);
  final String mediaItemId;
}

final class TxtImportEncodingChoiceRequired extends TxtImportResult {
  const TxtImportEncodingChoiceRequired(this.choice);
  final TxtEncodingChoiceRequired choice;
}

final class TxtImportFailed extends TxtImportResult {
  const TxtImportFailed(this.failure);
  final AppFailure failure;
}

final class ImportTxt {
  const ImportTxt({
    required this.decodeTxtSource,
    required this.chapterDetector,
    required this.importRepository,
    required this.derivedTxtStore,
    required this.idGenerator,
    required this.clock,
  });

  final DecodeTxtSource decodeTxtSource;
  final TxtChapterDetector chapterDetector;
  final ImportRepository importRepository;
  final DerivedTxtStore derivedTxtStore;
  final IdGenerator idGenerator;
  final ImportClock clock;

  Future<TxtImportResult> call({
    required TxtSourceCandidate candidate,
    required String title,
    TxtEncoding? selectedEncoding,
  }) async {
    if (title.trim().isEmpty) {
      return TxtImportFailed(AppFailure.fromCode(AppErrorCode.parseFailed));
    }

    final duplicate = await importRepository.findCompletedByFingerprint(
      candidate.fingerprint,
    );
    if (duplicate != null) {
      return TxtImportDuplicate(duplicate.mediaItemId!);
    }

    final decoding = await decodeTxtSource(
      candidate,
      selectedEncoding: selectedEncoding,
    );
    if (decoding is TxtEncodingChoiceRequired) {
      return TxtImportEncodingChoiceRequired(decoding);
    }
    if (decoding is TxtDecodingFailed) {
      return TxtImportFailed(decoding.failure);
    }
    final decoded = decoding as DecodedTxt;

    StagedDerivedTxt? staged;
    var promoted = false;
    try {
      final chapters = chapterDetector.detect(decoded);
      if (chapters.isEmpty) {
        throw const _ImportParseException();
      }

      final now = clock().toUtc();
      final mediaId = idGenerator.newId();
      final importId = idGenerator.newId();
      staged = await derivedTxtStore.stage(
        mediaItemId: mediaId,
        text: decoded.text,
      );
      final contentUnits = <ContentUnit>[
        for (var index = 0; index < chapters.length; index++)
          ContentUnit(
            id: idGenerator.newId(),
            mediaItemId: mediaId,
            unitType: ContentUnitType.chapter,
            title: chapters[index].title,
            orderIndex: index,
            contentRef: staged.contentRef,
            sourceLocator:
                'txt-v1:${chapters[index].startOffset}:'
                '${chapters[index].bodyStartOffset}:'
                '${chapters[index].endOffset}',
            contentHash: sha256
                .convert(
                  utf8.encode(
                    decoded.text.substring(
                      chapters[index].startOffset,
                      chapters[index].endOffset,
                    ),
                  ),
                )
                .toString(),
          ),
      ];
      final successfulImport = SuccessfulImport(
        mediaItem: MediaItem(
          id: mediaId,
          mediaType: MediaType.novel,
          title: title.trim(),
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
          id: importId,
          mediaItemId: mediaId,
          sourcePath: candidate.path,
          sourceKind: ImportSourceKind.txtFile,
          fileSize: candidate.fileSize,
          modifiedAt: candidate.modifiedAt,
          fingerprint: candidate.fingerprint,
          textEncoding: decoded.encoding,
          status: ImportStatus.completed,
          createdAt: now,
        ),
      );

      await importRepository.commitSuccessfulImport(
        successfulImport,
        beforeCommit: () async {
          await derivedTxtStore.promote(staged!);
          promoted = true;
        },
      );
      return TxtImportSucceeded(mediaId);
    } on Object catch (error) {
      final code = error is _ImportParseException
          ? AppErrorCode.parseFailed
          : AppErrorCode.storageFailed;
      if (staged != null) {
        if (promoted) {
          await _ignoreCleanup(() => derivedTxtStore.removeCommitted(staged!));
        } else {
          await _ignoreCleanup(() => derivedTxtStore.discard(staged!));
        }
      }
      await _recordFailure(candidate, decoded.encoding, code);
      logAppWarning(code.value, stage: 'import_txt');
      return TxtImportFailed(AppFailure.fromCode(code));
    }
  }

  Future<void> _recordFailure(
    TxtSourceCandidate candidate,
    TxtEncoding encoding,
    AppErrorCode code,
  ) async {
    try {
      await importRepository.recordFailure(
        ImportRecord(
          id: idGenerator.newId(),
          sourcePath: candidate.path,
          sourceKind: ImportSourceKind.txtFile,
          fileSize: candidate.fileSize,
          modifiedAt: candidate.modifiedAt,
          fingerprint: candidate.fingerprint,
          textEncoding: encoding,
          status: ImportStatus.failed,
          errorCode: code.value,
          createdAt: clock().toUtc(),
        ),
      );
    } on Object {
      // The stable result remains storage_failed; sensitive details are dropped.
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

final class _ImportParseException implements Exception {
  const _ImportParseException();
}
