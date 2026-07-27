# M01-005 本地数据库与迁移设计

## 1. 目标

为 mirascope MVP 0.1 建立可迁移、可测试且与 Flutter 界面隔离的本地数据层，为媒体库、TXT 导入、章节阅读、进度恢复和阅读设置提供稳定基础。

本阶段采用 Drift + SQLite，实现 schema v1、领域模型、Repository 接口与 Drift 实现、事务边界、数据库启动装配、schema 快照和迁移测试。

## 2. 范围

schema v1 包含：

- `MediaItem`；
- `LibraryEntry`；
- `ContentUnit`；
- `ReadingProgress`；
- `ReaderPreference`；
- `ImportRecord`。

本阶段不包含：

- `Bookmark`，该实体属于 MVP 0.2；
- 文件选择和文件权限；
- TXT 编码识别与章节解析；
- 媒体库正式界面；
- 阅读器正式功能；
- 云同步；
- 自动删除、移动或复制用户原始文件。

## 3. 已确认的建模规则

### 3.1 标识

所有领域实体使用应用生成的字符串 UUID。数据库不依赖自增整数产生领域身份。

UUID 在写入事务前生成，使测试、重新解析、文件重新定位和未来多设备同步都能保持稳定身份。

### 3.2 枚举

媒体类型、章节类型、导入来源、导入状态、设置范围和阅读模式以稳定英文字符串保存，并由数据库检查约束限制合法值。

不得保存 Dart 枚举的顺序值，避免调整枚举声明顺序后错误解释旧数据。

### 3.3 时间

时间统一保存为 UTC 毫秒时间戳，领域层使用 `DateTime`。显示时才转换为用户本地时间。

`lastOpenedAt`、`archivedAt`、`modifiedAt` 等非必有时间使用 `NULL` 表示缺失，不使用特殊时间值。

### 3.4 删除

从媒体库移除只更新 `LibraryEntry.archivedAt`。恢复归档复用原记录。

永久删除应用数据必须通过 Repository 的显式事务操作。删除 `MediaItem` 时，数据库级联删除其书架记录、章节、进度、作品阅读设置和导入记录。

任何数据库操作都不得删除或修改用户选择的原始 TXT 文件。

## 4. 分层与目录

数据访问遵循以下依赖方向：

```text
页面 / Use Case
      ↓
Repository 接口与领域模型
      ↓
Drift Repository 实现
      ↓
AppDatabase / SQLite
```

建议文件布局：

```text
lib/src/core/database/
├── app_database.dart
├── database_connection.dart
├── converters/
├── migrations/
└── tables/

lib/src/features/library/domain/
├── media_item.dart
├── library_entry.dart
└── media_library_repository.dart

lib/src/features/novel/domain/
├── content_unit.dart
├── reading_progress.dart
└── reading_progress_repository.dart

lib/src/features/settings/domain/
├── reader_preference.dart
└── reader_preference_repository.dart

lib/src/features/importing/domain/
├── import_record.dart
└── import_repository.dart

lib/src/features/*/data/
└── drift_*_repository.dart
```

`AppDatabase` 负责表、索引、外键、事务和迁移。Repository 实现负责 Drift 数据类与领域模型之间的映射。

Widget、页面和领域接口不得暴露或接收 Drift 生成的数据类。数据库通过 Riverpod 注入，测试以覆盖 Provider 或直接构造 Repository 的方式使用内存数据库。

## 5. schema v1

### 5.1 `media_items`

字段：

- `id`：UUID 文本主键；
- `media_type`：稳定枚举字符串；
- `title`：必填标题；
- `subtitle`、`creator`、`description`、`cover_ref`：可空文本；
- `created_at`、`updated_at`：UTC 毫秒。

索引：

- `(media_type, updated_at)`。

标题不是唯一键。

### 5.2 `library_entries`

字段：

- `id`：UUID 文本主键；
- `media_item_id`：指向 `media_items` 的唯一外键；
- `favorite`：布尔值；
- `added_at`：UTC 毫秒；
- `last_opened_at`、`archived_at`：可空 UTC 毫秒。

一个作品最多对应一条书架记录。归档和恢复更新同一行，归档不触发级联删除。

### 5.3 `content_units`

字段：

- `id`：UUID 文本主键；
- `media_item_id`：作品外键；
- `unit_type`：稳定枚举字符串；
- `title`：章节标题；
- `order_index`：非负整数；
- `content_ref`：应用派生内容引用；
- `source_locator`：源文件中的稳定定位信息；
- `content_hash`：章节内容哈希。

约束：

- `(media_item_id, order_index)` 唯一；
- `order_index >= 0`。

### 5.4 `reading_progress`

字段：

- `id`：UUID 文本主键；
- `media_item_id`：唯一作品外键；
- `content_unit_id`：章节外键；
- `locator`：章节内语义位置；
- `fraction`：用于展示的 `0.0` 至 `1.0` 数值；
- `updated_at`：UTC 毫秒；
- `revision`：非负整数。

约束：

- 每个作品最多一条当前进度；
- `fraction` 位于闭区间 `[0, 1]`；
- `revision >= 0`；
- 旧 revision 不得覆盖新进度。

### 5.5 `reader_preferences`

字段：

- `id`：UUID 文本主键；
- `scope`：`global` 或 `mediaItem`；
- `media_item_id`：作品范围时必填，全局范围时为空；
- `font_size`、`line_height`、`theme_key`、`reading_mode`：可空设置；
- `updated_at`：UTC 毫秒。

约束：

- 只允许一条全局设置；
- 每个作品最多一条作品设置；
- `scope` 与 `media_item_id` 的空值关系必须一致；
- 作品设置缺失的字段按“作品设置、全局设置、程序默认值”的顺序回退。

### 5.6 `import_records`

字段：

- `id`：UUID 文本主键；
- `media_item_id`：作品外键；
- `source_path`：来源路径；
- `source_kind`：稳定枚举字符串；
- `file_size`：非负整数；
- `modified_at`：可空 UTC 毫秒；
- `fingerprint`：文件大小与完整内容哈希形成的稳定指纹；
- `status`：`pending`、`completed`、`failed` 或 `missing`；
- `error_code`：失败时的稳定错误码；
- `created_at`：UTC 毫秒。

索引：

- `fingerprint` 普通索引。

指纹不设唯一约束，因为同一内容可能对应不同路径，也可能存在多次导入尝试。

## 6. Repository 边界

### 6.1 `MediaLibraryRepository`

职责：

- 监听未归档或指定范围的书架列表；
- 按 ID 获取作品；
- 归档和恢复书架条目；
- 在明确的永久删除操作中删除作品聚合。

它不检查或修改文件系统。

### 6.2 `ImportRepository`

职责：

- 按指纹查找有效导入；
- 记录安全、可解释的失败导入；
- 在单个事务中提交作品、书架条目、章节和成功导入记录。

事务中任何一步失败都必须回滚整组写入，不留下半完成作品。

### 6.3 `ReadingProgressRepository`

职责：

- 读取作品当前进度；
- 保存带 revision 的新进度；
- 拒绝旧 revision 覆盖新进度，并返回可区分的冲突结果。

### 6.4 `ReaderPreferenceRepository`

职责：

- 读取全局设置；
- 读取作品设置；
- 计算作品设置、全局设置和程序默认值的有效结果；
- 验证并保存设置。

## 7. 数据流

后续 TXT 导入成功流程：

```text
TXT 导入用例
  → 检查文件并计算指纹
  → 解析章节
  → ImportRepository 开启事务
  → 写入作品、书架、章节和导入记录
  → 提交事务
  → 媒体库监听流刷新
```

解析前失败只记录安全错误码。数据库事务失败时回滚作品、书架和章节，不删除或修改用户原文件。

## 8. 数据库连接与启动

正式数据库文件名为 `mirascope.sqlite`，保存在操作系统提供的应用数据目录。不得把正式数据库写入仓库目录。

启动顺序：

```text
Flutter binding
  → 日志基础初始化
  → 打开数据库
  → 校验或迁移 schema
  → 通过 Riverpod 注入数据库和 Repository
  → 启动 MirascopeApp
```

测试使用内存数据库，并确保每个测试关闭自己的连接。

数据库打开或迁移失败时：

- 不删除数据库；
- 不自动创建替代数据库覆盖原文件；
- 不向 UI 或普通日志暴露完整私人路径、正文或原始异常；
- 启动安全错误页显示稳定代码 `database_open_failed`；
- 保留未来受控诊断接口的扩展位置。

## 9. 迁移

- 正式 schema 从版本 1 开始；
- schema 版本只能递增；
- v1 schema 快照纳入 Git；
- 已发布快照不可原地修改；
- 迁移必须在事务中执行；
- 失败时保留旧 schema 和旧数据；
- 数据库失败不得触发自动删库或无提示重建。

v1 没有真实的旧发布数据库，因此不伪造生产 v0。测试使用空旧 schema 验证升级入口，并使用故意失败的测试迁移验证事务回滚。

后续 schema v2 开始，每次迁移必须从上一份已提交快照创建数据库并升级到当前版本。

## 10. 测试策略

### 10.1 结构测试

验证：

- 六张表均可创建；
- 外键已开启；
- 唯一索引、普通索引和检查约束生效；
- 非法枚举、负数、重复章节顺序和越界进度被拒绝。

### 10.2 Repository 测试

验证：

- 媒体库查询、归档和恢复；
- 同一作品不会产生两个书架条目；
- 作品设置正确覆盖全局设置；
- 旧 revision 不能覆盖新阅读进度；
- 永久删除应用数据会清理从属记录。

### 10.3 事务测试

验证：

- 成功导入原子写入作品、书架、章节和导入记录；
- 中途失败不留下半完成实体；
- 失败不触碰测试代表的原始文件。

### 10.4 迁移测试

验证：

- 空库初始化为 v1；
- 测试旧 schema 可进入 v1；
- 故意失败的迁移回滚；
- 失败后旧数据仍可读取；
- schema 快照与当前代码一致。

## 11. 完成标准

- schema v1、约束、索引和外键实现；
- 四个 Repository 边界具有领域接口与 Drift 实现；
- Drift 生成类型未泄漏到 Widget 和领域接口；
- 正式数据库通过 Riverpod 注入启动流程；
- 数据库失败显示安全错误码且不删库；
- 结构、Repository、事务和迁移测试全部通过；
- `dart run build_runner build`、`flutter analyze`、`flutter test` 通过；
- Windows 原生工具链若仍受外部环境阻塞，必须继续单独记录，不得用 Dart 测试替代 Windows 构建结论。
