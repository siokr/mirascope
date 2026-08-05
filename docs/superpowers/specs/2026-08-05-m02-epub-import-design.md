# MVP 0.2 EPUB 导入与基础阅读设计

## 1. 目标

在 Windows 完成无 DRM EPUB 2/3 的导入、目录、阅读和进度恢复闭环，并复用现有书架、详情、归档、彻底删除和来源重新定位能力。

本阶段不支持 DRM、固定版式像素级还原、脚本与表单、远程资源、音视频/SMIL、复杂 MathML、完整 CSS 和多 rendition。遇到这些内容时必须安全拒绝或降级，不执行活动内容，也不联网补资源。

## 2. 支持边界

- 读取 `META-INF/container.xml` 与一个主 OPF package；
- 兼容 EPUB 2 NCX 和 EPUB 3 navigation document；
- 以 spine 作为阅读顺序，目录只提供标题和跳转关系；
- 支持 UTF-8/UTF-16 XML、XHTML；
- 提取标题、作者等基础元数据；
- 规范化段落、标题、列表、引用、分隔线、强调文本和本地图片；
- 支持片段定位、目录缺失以及未列入目录的 spine 文档。

## 3. 依赖策略

优先组合使用 `archive`、`xml` 和 `html`，不直接采用高层 EPUB 包。这样可以显式控制 ZIP 路径、解压预算、外部资源、脚本、DRM 和原子落盘。正式锁定版本前必须完成许可证、维护状态、Windows/Android 兼容性和最小样本验证。

## 4. 导入流水线

```text
选择文件
→ 类型/大小/指纹/重复项检查
→ 安全读取 ZIP
→ 解析 container.xml 和 OPF
→ 建立 manifest、spine、目录关系
→ XHTML 转换为语义块
→ 暂存章节 JSON、图片与 manifest
→ 提升暂存目录
→ 原子提交数据库
```

任何一步失败都不得产生可见的半成品媒体项；数据库提交失败时清理本次暂存和已提升内容，保留已有数据。

## 5. ZIP 与资源安全

所有 ZIP entry 和 EPUB 内部引用统一使用 `/`，URI 解码前后各验证一次。拒绝绝对路径、盘符、空段、`.`、`..`、反斜杠逃逸、NUL，以及解析后离开容器根目录的引用。资源匹配区分大小写。

第一版预算：

- EPUB 文件最大 100 MiB；
- entry 最多 10,000 个；
- 单 entry 解压后最大 32 MiB；
- 累计解压最大 512 MiB；
- 单 entry 压缩比最大 200:1；
- spine 文档最多 5,000 个；
- 单张派生图片最大 20 MiB。

预算值通过样本和性能测试校准，但在实现前必须存在。加密正文或图片返回 DRM 不支持；脚本、事件属性、表单、iframe、插件和远程 URL 不进入阅读模型。

## 6. 派生内容

```text
derived_epub/<media-id>/manifest.json
derived_epub/<media-id>/chapters/<chapter-id>.json
derived_epub/<media-id>/images/<hash>.<ext>
```

章节 JSON 保存稳定的语义块，而不是原始 HTML。块类型包括 paragraph、heading、list、quote、divider 和 local-image；文本块包含可选强调 span。`ContentUnit.contentRef` 使用 `epub/<media-id>/<chapter-id>.json`，`sourceLocator` 使用 `epub-v1:<manifest-id>:<fragment>`。内容哈希覆盖规范化后的章节 JSON。

## 7. 目录、阅读与进度

目录目标先映射 manifest 文档，再解析 fragment；无法命中的目录项不破坏 spine 阅读。没有目录时，以 spine 文档或首个可用标题生成稳定章节名。

进度定位使用：

```text
epub-block-v1:<block-index>:<text-offset>
```

恢复时先匹配章节，再匹配语义块和文本偏移；越界时收敛到最近有效位置。TXT 的定位和行为保持不变。

## 8. 稳定错误码

- `epub_invalid_container`
- `epub_package_missing`
- `epub_manifest_invalid`
- `epub_spine_empty`
- `epub_resource_missing`
- `epub_unsafe_path`
- `epub_resource_limit`
- `epub_drm_unsupported`
- `epub_content_unsupported`

界面显示可行动的中文信息，日志继续执行现有脱敏约束。

## 9. 验证样本

测试语料必须自建或确认可再分发，覆盖 EPUB 2/3、NCX/nav、spine 与目录顺序不同、命名空间、fragment、图片、无目录、资源缺失、路径穿越、外部资源、脚本、加密、资源预算、事务回滚、重复导入、来源丢失、进度恢复和彻底删除。

## 10. 完成标准

- Windows 可从界面导入并阅读受支持 EPUB；
- 危险、加密和超预算文件以稳定错误安全失败；
- 章节跳转及语义进度恢复正确；
- TXT 全部回归通过；
- 格式化、静态分析和自动化测试通过；
- 在干净 Windows Sandbox 完成人工验收。
