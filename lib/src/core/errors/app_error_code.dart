enum AppErrorCode {
  startupFailed('startup_failed', '应用启动失败', '请重试；如果问题持续存在，请重新启动应用。'),
  databaseOpenFailed('database_open_failed', '无法打开本地数据', '请重试；应用不会修改或删除你的原文件。'),
  libraryLoadFailed('library_load_failed', '无法加载媒体库', '请稍后重试。'),
  libraryOpenFailed('library_open_failed', '无法打开作品', '请稍后重试。'),
  libraryArchiveFailed('library_archive_failed', '无法归档作品', '请稍后重试。'),
  libraryRestoreFailed('library_restore_failed', '无法恢复作品', '请稍后重试。'),
  libraryDeleteFailed('library_delete_failed', '无法删除作品', '请稍后重试。'),
  fileNotFound('file_not_found', '找不到所选文件', '请重新选择文件。'),
  filePermissionDenied(
    'file_permission_denied',
    '没有权限读取所选文件',
    '请调整文件权限，或复制文件后重试。',
  ),
  emptyFile('empty_file', '所选文件为空', '请选择包含内容的文件。'),
  encodingUnknown('encoding_unknown', '无法可靠识别文本编码', '请选择编码并预览。'),
  decodeFailed('decode_failed', '无法按所选编码读取文本', '请更换编码或取消导入。'),
  noReadableContent('no_readable_content', '文件中没有可读正文', '请检查文件内容。'),
  importDuplicate('import_duplicate', '这个文件已经导入', '打开已有作品即可。'),
  epubInvalidContainer(
    'epub_invalid_container',
    '所选文件不是有效的 EPUB',
    '请选择未损坏的 EPUB 文件。',
  ),
  epubResourceLimit(
    'epub_resource_limit',
    'EPUB 文件超出安全限制',
    '请选择不超过 100 MiB 的 EPUB 文件。',
  ),
  epubUnsafePath(
    'epub_unsafe_path',
    'EPUB 包含不安全的内部路径',
    '请选择来源可信且未损坏的 EPUB 文件。',
  ),
  epubResourceMissing('epub_resource_missing', 'EPUB 缺少必要资源', '请检查文件是否完整。'),
  epubPackageMissing('epub_package_missing', 'EPUB 缺少书籍描述文件', '请检查文件是否完整。'),
  epubManifestInvalid(
    'epub_manifest_invalid',
    'EPUB 书籍结构无效',
    '请选择结构完整的 EPUB 文件。',
  ),
  epubSpineEmpty('epub_spine_empty', 'EPUB 没有可阅读内容', '请选择包含正文的 EPUB 文件。'),
  epubDrmUnsupported(
    'epub_drm_unsupported',
    '暂不支持受 DRM 保护的 EPUB',
    '请选择未加密且可合法阅读的 EPUB 文件。',
  ),
  epubContentUnsupported(
    'epub_content_unsupported',
    'EPUB 正文格式暂不支持',
    '请选择使用常规流式 XHTML 正文的 EPUB 文件。',
  ),
  mangaInvalidSource(
    'manga_invalid_source',
    '所选内容不是有效的漫画来源',
    '请选择漫画目录或 ZIP/CBZ 压缩包。',
  ),
  mangaNoImages(
    'manga_no_images',
    '漫画来源中没有支持的图片',
    '请选择包含 JPEG、PNG 或 WebP 图片的目录。',
  ),
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
