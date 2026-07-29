enum AppErrorCode {
  startupFailed('startup_failed', '应用启动失败', '请重试；如果问题持续存在，请重新启动应用。'),
  databaseOpenFailed('database_open_failed', '无法打开本地数据', '请重试；应用不会修改或删除你的原文件。'),
  libraryLoadFailed('library_load_failed', '无法加载媒体库', '请稍后重试。'),
  libraryOpenFailed('library_open_failed', '无法打开作品', '请稍后重试。'),
  libraryArchiveFailed('library_archive_failed', '无法归档作品', '请稍后重试。'),
  libraryRestoreFailed('library_restore_failed', '无法恢复作品', '请稍后重试。'),
  fileNotFound('file_not_found', '找不到所选文件', '请重新选择文件。'),
  filePermissionDenied(
    'file_permission_denied',
    '没有权限读取所选文件',
    '请调整文件权限，或复制文件后重试。',
  ),
  emptyFile('empty_file', '所选文件为空', '请选择包含正文的 TXT 文件。'),
  encodingUnknown('encoding_unknown', '无法可靠识别文本编码', '请选择编码并预览。'),
  decodeFailed('decode_failed', '无法按所选编码读取文本', '请更换编码或取消导入。'),
  noReadableContent('no_readable_content', '文件中没有可读正文', '请检查文件内容。'),
  importDuplicate('import_duplicate', '这个文件已经导入', '打开已有作品即可。'),
  parseFailed('parse_failed', '无法解析文件内容', '请检查文件后重试。'),
  storageFailed('storage_failed', '无法保存导入结果', '请稍后重试。'),
  sourceChanged('source_changed', '原文件内容已经变化', '确认重新解析或取消。');

  const AppErrorCode(this.value, this.message, this.recovery);

  final String value;
  final String message;
  final String recovery;

  static AppErrorCode? tryParse(String value) {
    for (final code in values) {
      if (code.value == value) {
        return code;
      }
    }
    return null;
  }
}
