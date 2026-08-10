# mirascope 本地数据模型

## 1. 文档职责

本文定义本地媒体库的数据语义、关系、约束、迁移和文件生命周期，是本地实体的单一信息源。服务端可以映射这些实体，但不得让本地阅读依赖网络。

## 2. 建模原则

- 数据库保存可查询且需要一致性的状态；原始文件和大体积内容保存在文件系统。
- 小说和漫画共享媒体库、进度和收藏语义，媒介特有信息独立扩展。
- 原始文件、应用派生数据和可删除缓存必须区分。
- 文件路径不是媒体身份；路径变化不自动创建新作品。
- 发布后的结构变化必须通过数据库迁移。

## 3. 核心实体

以下是稳定领域名称，数据库表名可采用复数下划线形式。

### 3.1 `MediaItem`

表示一部作品。核心字段为 `id`、`mediaType`、`title`、`subtitle`、`creator`、`description`、`coverRef`、`createdAt` 和 `updatedAt`。

标题不是唯一键。`updatedAt` 用于本地排序和诊断，不是未来同步冲突的唯一依据。

### 3.2 `LibraryEntry`

表示作品在当前资料库中的管理状态。字段包括 `id`、`mediaItemId`、`favorite`、`addedAt`、`lastOpenedAt` 和 `archivedAt`。

每个 `MediaItem` 最多有一个活动条目。移出媒体库不自动删除用户原文件。

### 3.3 `ContentUnit`

表示有序内容单元，例如小说章节或漫画章节。字段包括 `id`、`mediaItemId`、`unitType`、`title`、`orderIndex`、`contentRef`、`sourceLocator` 和 `contentHash`。

`(mediaItemId, orderIndex)` 唯一。重新解析时优先通过指纹和相邻关系保持 ID 稳定。

### 3.4 `ReadingProgress`

表示作品当前可恢复位置。字段包括 `id`、`mediaItemId`、`contentUnitId`、`locator`、`fraction`、`updatedAt` 和 `revision`。

每个作品只有一个当前进度。恢复以 `contentUnitId + locator` 为准，`fraction` 只用于展示。写入必须原子化，旧 `revision` 不得覆盖新值。

### 3.5 `Bookmark`

表示用户显式保存的位置。字段包括 `id`、`mediaItemId`、`contentUnitId`、`locator`、`label`、`createdAt` 和 `deletedAt`。

书签属于 MVP 0.2；提前定义是为了保持数据边界稳定。

### 3.6 `ReaderPreference`

表示持久化阅读偏好。字段包括 `id`、`scope`、`mediaItemId`、`fontSize`、`lineHeight`、`themeKey`、`readingMode` 和 `updatedAt`。

作品设置覆盖全局设置；缺少的字段回退到全局值。

### 3.7 `ImportRecord`

表示一次导入及其可追踪状态。字段包括 `id`、`mediaItemId`、`sourcePath`、`sourceKind`、`fileSize`、`modifiedAt`、`fingerprint`、`textEncoding`、`status`、`errorCode` 和 `createdAt`。

`sourceKind` 可取 `txtFile`、`epubFile`、`mangaDirectory`、`mangaArchive`；`status` 可取 `pending`、`completed`、`failed`、`missing`。

成功记录必须关联 `MediaItem`；失败记录在媒体事务已回滚时允许 `mediaItemId` 为空。TXT 成功记录必须保存实际使用的 `textEncoding`；旧 schema 迁移时不得猜测历史编码。

### 3.8 `MangaPage`

表示漫画章节内固化顺序的一页。字段包括 `id`、`contentUnitId`、`orderIndex`、`contentRef`、`sourceLocator`、`contentHash`、`mimeType`、`byteLength`、`pixelWidth` 和 `pixelHeight`。

`(contentUnitId, orderIndex)` 唯一。图片尺寸在尚未解码时允许为空，成功解码后必须为正数。页面来源变化时通过 `contentHash` 使旧缓存失效。

### 3.9 `MangaReaderPreference`

表示漫画作品专属阅读偏好。字段包括 `id`、`mediaItemId`、`readingMode`、`pageTurnDirection` 和 `updatedAt`。每部漫画最多一条；`readingMode` 为 `vertical` 或 `horizontal`，翻页方向为 `leftToRight` 或 `rightToLeft`。

漫画进度继续使用共享 `ReadingProgress`，locator 格式为 `page:<页索引>:<页内比例>`。页内比例限制在 `0..1`，恢复不依赖窗口像素。

## 4. 关系

```text
MediaItem 1 --- 0..1 LibraryEntry
MediaItem 1 --- 1..n ContentUnit
MediaItem 1 --- 0..1 ReadingProgress
MediaItem 1 --- 0..n Bookmark
MediaItem 1 --- 0..1 ReaderPreference(mediaItem scope)
MediaItem 1 --- 0..n ImportRecord
MediaItem 1 --- 0..1 MangaReaderPreference
ContentUnit 1 --- 0..n MangaPage
```

应用层不得绕过 Repository 分别删除相关表。

## 5. 文件身份与重复导入

MVP 0.1 的指纹由文件大小和内容哈希组成。可以先快速筛选候选，再以完整哈希确认，不能只按文件名或路径判断。

- 指纹相同且记录有效：提示已导入并打开已有条目；
- 路径相同但指纹变化：作为更新候选，不静默覆盖；
- 指纹相同但路径变化：更新可用路径或增加来源记录；
- 标题相同但指纹不同：作为不同内容，由用户决定。

文件丢失时将导入记录标记为 `missing`，保留作品、进度和书签并允许重新定位；新文件指纹匹配后恢复关联。

## 6. 存储与生命周期

### 6.1 用户原始文件

默认保留在用户选择的位置，应用不拥有删除权。未来若提供复制到资料库，必须区分引用模式与托管模式。

### 6.2 应用派生数据

章节索引、规范化文本和缩略图由应用管理。它们可以从原文件重建，但删除前不得破坏当前离线阅读能力。

### 6.3 缓存

缓存必须可统计和清理。清理缓存不删除 `MediaItem`、进度、书签或用户原文件。

## 7. 删除语义

- 从媒体库移除：归档 `LibraryEntry`；
- 删除应用数据：确认后删除派生数据和从属记录，不删除引用的原文件；
- 清理缓存：只删除可重建内容；
- 恢复归档：重新激活原条目，不创建重复实体；
- 为 Version 0.4 保留删除事件或 `deletedAt`，MVP 0.1 不实现云传播。

## 8. 索引与约束

至少需要：

- `library_entries(media_item_id)` 的唯一活动约束；
- `content_units(media_item_id, order_index)` 唯一索引；
- `reading_progress(media_item_id)` 唯一索引；
- `bookmarks(media_item_id, created_at)` 索引；
- `import_records(fingerprint)` 索引；
- `media_items(media_type, updated_at)` 索引。

外键删除策略必须显式声明。媒体库归档不触发级联。

## 9. 迁移规则

- schema 版本单调递增；
- 迁移只前进，并在事务中执行；
- 失败时保持旧 schema 可用；
- 每次迁移至少测试空库和上一发布版本升级；
- 进度定位格式变化时提供转换或兼容读取；
- 发布说明记录数据迁移和风险。

## 10. Repository 边界

建议接口：

```text
MediaLibraryRepository
ImportRepository
ReadingProgressRepository
ReaderPreferenceRepository
BookmarkRepository
```

导入用例协调文件检查、解析、数据库事务和派生文件清理。失败必须留下可解释的 `ImportRecord`，并回滚不完整实体。

## 11. 验收场景

- 新 TXT 导入后形成一致的媒体、章节和导入记录；
- 重新启动后恢复同一章节和语义位置；
- 重复导入不会创建两个活动条目；
- 数据库写入失败不留下半完成条目；
- 文件丢失时保留元数据和进度，并可重新定位；
- 迁移失败不部分修改旧数据；
- 清理缓存不删除原文件、媒体或进度。

## 12. 同步约束

Version 0.4 必须映射稳定 ID、`revision` 和删除语义。客户端 `updatedAt` 不能成为跨设备冲突的唯一依据，具体协议以 `docs/sync-protocol.md` 为准。
