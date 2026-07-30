final class StagedDerivedTxt {
  const StagedDerivedTxt({
    required this.contentRef,
    required this.temporaryToken,
  });

  final String contentRef;
  final String temporaryToken;
}

abstract interface class DerivedTxtStore {
  Future<StagedDerivedTxt> stage({
    required String mediaItemId,
    required String text,
  });

  Future<void> promote(StagedDerivedTxt staged);

  Future<void> discard(StagedDerivedTxt staged);

  Future<void> removeCommitted(StagedDerivedTxt staged);

  Future<void> removeCommittedRef(String contentRef);
}
