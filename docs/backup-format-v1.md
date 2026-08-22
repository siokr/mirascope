# Mirascope 备份格式 v1

## 目标

备份用于在同一或更高兼容版本的 Mirascope 中恢复本地媒体库、阅读状态和应用托管内容。备份不是用户原始媒体文件的副本，也不替代用户对原始 TXT、EPUB、ZIP、CBZ 或图片的独立保存。

## 容器

- 文件扩展名使用 `.mirascope-backup.zip`；
- 容器为 ZIP，根目录必须包含 `manifest.json`；
- 当前 `schemaVersion` 为 `1`；
- 所有文件路径使用 `/`，禁止绝对路径、反斜杠、盘符、空路径段、`.` 和 `..`；
- 清单之外的文件、清单中缺失的文件、重复路径或符号链接均视为无效备份。

## 清单

`manifest.json` 包含：

- `format`: 固定为 `mirascope-backup`；
- `schemaVersion`: 备份容器结构版本；
- `databaseSchemaVersion`: 导出时的 Drift 数据库版本；
- `createdAt`: UTC ISO 8601 时间；
- `files`: 文件列表，每项记录相对路径、字节数和小写 SHA-256。

恢复前必须先完成整个容器的路径、文件集合、字节数和 SHA-256 校验。任何一项失败都不得改动当前数据。

## v1 数据范围

纳入备份：

- `data/mirascope.sqlite`；
- `data/derived_txt`；
- `data/derived_epub`；
- `data/derived_manga/content`；
- `data/custom_covers`。

不纳入备份：

- 用户原始 TXT、EPUB、ZIP、CBZ、漫画目录或封面图片；
- `derived_manga/cache` 等可重新生成的缓存；
- 日志、临时文件、数据库旁路临时文件和未提交的 staging 内容；
- 签名密钥、密码或在线模块凭据。

## 恢复原则

后续恢复实现必须先解压到独立临时目录并复验，再关闭数据库连接，以目录级替换完成提交。提交前保留当前数据快照；替换失败时回滚，不能把已验证文件逐个覆盖到正在使用的数据目录。
