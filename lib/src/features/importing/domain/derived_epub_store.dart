import 'epub_container.dart';
import 'epub_semantic_content.dart';
import 'parsed_epub.dart';

final class DerivedEpubChapter {
  const DerivedEpubChapter({
    required this.contentRef,
    required this.contentHash,
  });

  final String contentRef;
  final String contentHash;
}

final class StagedDerivedEpub {
  StagedDerivedEpub({
    required this.mediaItemId,
    required this.temporaryToken,
    required List<DerivedEpubChapter> chapters,
  }) : chapters = List.unmodifiable(chapters);

  final String mediaItemId;
  final String temporaryToken;
  final List<DerivedEpubChapter> chapters;
}

abstract interface class DerivedEpubStore {
  Future<StagedDerivedEpub> stage({
    required String mediaItemId,
    required ParsedEpub book,
    required List<EpubSemanticChapter> chapters,
    required EpubContainer container,
  });

  Future<void> promote(StagedDerivedEpub staged);

  Future<void> discard(StagedDerivedEpub staged);

  Future<void> removeCommitted(StagedDerivedEpub staged);

  Future<void> removeCommittedRef(String contentRef);
}
