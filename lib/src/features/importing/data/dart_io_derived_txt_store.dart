import 'dart:convert';
import 'dart:io';

import '../domain/derived_txt_store.dart';

final class DartIoDerivedTxtStore implements DerivedTxtStore {
  DartIoDerivedTxtStore(this.rootDirectory);

  final Directory rootDirectory;

  @override
  Future<StagedDerivedTxt> stage({
    required String mediaItemId,
    required String text,
  }) async {
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(mediaItemId)) {
      throw ArgumentError.value(mediaItemId, 'mediaItemId', 'Unsafe media ID');
    }
    final stagingDirectory = Directory(
      '${rootDirectory.path}${Platform.pathSeparator}staging',
    );
    await stagingDirectory.create(recursive: true);
    final temporaryPath =
        '${stagingDirectory.path}${Platform.pathSeparator}$mediaItemId.txt.tmp';
    final file = File(temporaryPath);
    await file.writeAsBytes(utf8.encode(text), flush: true);
    return StagedDerivedTxt(
      contentRef: 'content/$mediaItemId.txt',
      temporaryToken: temporaryPath,
    );
  }

  @override
  Future<void> promote(StagedDerivedTxt staged) async {
    final source = File(staged.temporaryToken);
    final target = _committedFile(staged);
    await target.parent.create(recursive: true);
    await source.rename(target.path);
  }

  @override
  Future<void> discard(StagedDerivedTxt staged) async {
    await _deleteIfPresent(File(staged.temporaryToken));
  }

  @override
  Future<void> removeCommitted(StagedDerivedTxt staged) async {
    await _deleteIfPresent(_committedFile(staged));
  }

  File _committedFile(StagedDerivedTxt staged) {
    final segments = staged.contentRef.split('/');
    if (segments.length != 2 ||
        segments.first != 'content' ||
        !RegExp(r'^[A-Za-z0-9_-]+\.txt$').hasMatch(segments.last)) {
      throw ArgumentError.value(
        staged.contentRef,
        'staged.contentRef',
        'Unsafe content reference',
      );
    }
    return File(
      '${rootDirectory.path}${Platform.pathSeparator}content'
      '${Platform.pathSeparator}${segments.last}',
    );
  }

  Future<void> _deleteIfPresent(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
