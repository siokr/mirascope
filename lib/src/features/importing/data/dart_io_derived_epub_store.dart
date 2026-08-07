import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/derived_epub_store.dart';
import '../domain/epub_container.dart';
import '../domain/epub_semantic_content.dart';
import '../domain/parsed_epub.dart';

final class DartIoDerivedEpubStore implements DerivedEpubStore {
  DartIoDerivedEpubStore(
    this.rootDirectory, {
    this.maximumImageBytes = 20 * 1024 * 1024,
  });

  final Directory rootDirectory;
  final int maximumImageBytes;

  @override
  Future<StagedDerivedEpub> stage({
    required String mediaItemId,
    required ParsedEpub book,
    required List<EpubSemanticChapter> chapters,
    required EpubContainer container,
  }) async {
    _validateMediaId(mediaItemId);
    final staging = Directory(
      '${rootDirectory.path}${Platform.pathSeparator}staging'
      '${Platform.pathSeparator}$mediaItemId.tmp',
    );
    await _deleteDirectoryIfPresent(staging);
    try {
      await staging.create(recursive: true);
      final images = <String, String>{};
      var imageBytes = 0;
      final derivedChapters = <DerivedEpubChapter>[];
      final manifestChapters = <Map<String, Object?>>[];

      for (var index = 0; index < chapters.length; index++) {
        final chapter = chapters[index];
        final blocks = <Map<String, Object?>>[];
        for (final block in chapter.blocks) {
          String? imageRef;
          if (block.kind == EpubBlockKind.image) {
            final sourcePath = block.imagePath!;
            imageRef = images[sourcePath];
            if (imageRef == null) {
              final bytes = await container.readBytes(sourcePath);
              imageBytes += bytes.length;
              if (imageBytes > maximumImageBytes) {
                throw AppFailure.fromCode(AppErrorCode.epubResourceLimit);
              }
              final digest = sha256.convert(bytes).toString();
              final extension = _imageExtension(block.imageMediaType!);
              imageRef = 'epub/$mediaItemId/images/$digest.$extension';
              images[sourcePath] = imageRef;
              final imageFile = File(
                '${staging.path}${Platform.pathSeparator}images'
                '${Platform.pathSeparator}$digest.$extension',
              );
              if (!await imageFile.exists()) {
                await imageFile.parent.create(recursive: true);
                await imageFile.writeAsBytes(bytes, flush: true);
              }
            }
          }
          blocks.add(_serializeBlock(block, imageRef: imageRef));
        }

        final chapterName = index.toString().padLeft(5, '0');
        final contentRef = 'epub/$mediaItemId/chapters/$chapterName.json';
        final payload = utf8.encode(
          jsonEncode(<String, Object?>{
            'schema': 'epub-derived-v1',
            'manifestId': chapter.manifestId,
            'sourcePath': chapter.sourcePath,
            'title': chapter.title,
            'linear': chapter.linear,
            'blocks': blocks,
          }),
        );
        final contentHash = sha256.convert(payload).toString();
        final chapterFile = File(
          '${staging.path}${Platform.pathSeparator}chapters'
          '${Platform.pathSeparator}$chapterName.json',
        );
        await chapterFile.parent.create(recursive: true);
        await chapterFile.writeAsBytes(payload, flush: true);
        derivedChapters.add(
          DerivedEpubChapter(contentRef: contentRef, contentHash: contentHash),
        );
        manifestChapters.add(<String, Object?>{
          'contentRef': contentRef,
          'contentHash': contentHash,
          'manifestId': chapter.manifestId,
        });
      }

      await File(
        '${staging.path}${Platform.pathSeparator}manifest.json',
      ).writeAsString(
        jsonEncode(<String, Object?>{
          'schema': 'epub-derived-v1',
          'version': book.version,
          'title': book.title,
          'authors': book.authors,
          'chapters': manifestChapters,
        }),
        flush: true,
      );
      return StagedDerivedEpub(
        mediaItemId: mediaItemId,
        temporaryToken: staging.path,
        chapters: derivedChapters,
      );
    } on Object {
      await _deleteDirectoryIfPresent(staging);
      rethrow;
    }
  }

  @override
  Future<void> promote(StagedDerivedEpub staged) async {
    _validateMediaId(staged.mediaItemId);
    final source = Directory(staged.temporaryToken);
    final target = _committedDirectory(staged.mediaItemId);
    await target.parent.create(recursive: true);
    if (await target.exists()) {
      throw StateError('Committed EPUB directory already exists');
    }
    await source.rename(target.path);
  }

  @override
  Future<void> discard(StagedDerivedEpub staged) =>
      _deleteDirectoryIfPresent(Directory(staged.temporaryToken));

  @override
  Future<void> removeCommitted(StagedDerivedEpub staged) =>
      _deleteDirectoryIfPresent(_committedDirectory(staged.mediaItemId));

  @override
  Future<void> removeCommittedRef(String contentRef) async {
    final match = RegExp(
      r'^epub/([A-Za-z0-9_-]+)/chapters/[0-9]{5}\.json$',
    ).firstMatch(contentRef);
    if (match == null) {
      throw ArgumentError.value(
        contentRef,
        'contentRef',
        'Unsafe EPUB content reference',
      );
    }
    await _deleteDirectoryIfPresent(_committedDirectory(match.group(1)!));
  }

  Directory _committedDirectory(String mediaItemId) => Directory(
    '${rootDirectory.path}${Platform.pathSeparator}content'
    '${Platform.pathSeparator}$mediaItemId',
  );

  Map<String, Object?> _serializeBlock(
    EpubSemanticBlock block, {
    String? imageRef,
  }) => <String, Object?>{
    'kind': block.kind.name,
    if (block.text != null) 'text': block.text,
    if (block.sourceId != null) 'sourceId': block.sourceId,
    if (block.headingLevel != null) 'headingLevel': block.headingLevel,
    if (block.listDepth != null) 'listDepth': block.listDepth,
    if (block.ordered != null) 'ordered': block.ordered,
    'imageRef': ?imageRef,
    if (block.imageMediaType != null) 'imageMediaType': block.imageMediaType,
    if (block.altText != null) 'altText': block.altText,
    if (block.styleSpans.isNotEmpty)
      'styleSpans': [
        for (final span in block.styleSpans)
          <String, Object?>{
            'start': span.start,
            'end': span.end,
            'bold': span.bold,
            'italic': span.italic,
          },
      ],
  };

  String _imageExtension(String mediaType) => switch (mediaType.toLowerCase()) {
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/gif' => 'gif',
    'image/webp' => 'webp',
    'image/bmp' => 'bmp',
    _ => throw AppFailure.fromCode(AppErrorCode.epubContentUnsupported),
  };

  void _validateMediaId(String mediaItemId) {
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(mediaItemId)) {
      throw ArgumentError.value(mediaItemId, 'mediaItemId', 'Unsafe media ID');
    }
  }

  Future<void> _deleteDirectoryIfPresent(Directory directory) async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}
