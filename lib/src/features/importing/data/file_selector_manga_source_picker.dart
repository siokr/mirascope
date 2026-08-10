import 'package:file_selector/file_selector.dart';

import '../domain/manga_source.dart';

final class FileSelectorMangaSourcePicker implements MangaSourcePicker {
  const FileSelectorMangaSourcePicker();

  static const _archiveTypeGroup = XTypeGroup(
    label: '漫画压缩包',
    extensions: <String>['zip', 'cbz'],
  );

  @override
  Future<String?> pickArchive() async {
    final file = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[_archiveTypeGroup],
      confirmButtonText: '选择',
    );
    return file?.path;
  }

  @override
  Future<String?> pickDirectory() =>
      getDirectoryPath(confirmButtonText: '选择', canCreateDirectories: false);
}
