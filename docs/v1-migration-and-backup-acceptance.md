# v1 迁移与备份恢复验收

本流程只在全新的 Windows 沙盒中执行。不要覆盖本机正在使用的应用数据。

项目没有已发布的 schema v1 生产版本，因此这里验证的是由已提交 v1 schema 快照生成的合成旧数据，不将结果表述为真实用户生产迁移。

## 1. 准备合成 v1 数据

在项目根目录运行：

```powershell
dart run tool/create_v1_acceptance_fixture.dart build\v1-acceptance-data
```

生成目录包含 `mirascope.sqlite` 和 `derived_txt`。工具拒绝覆盖已有目录；需要重跑时，请先手动确认并删除旧的生成目录。

## 2. 在 Windows 沙盒验证升级

1. 启动全新的 Windows 沙盒，将候选版压缩包和 `build\v1-acceptance-data` 复制进去。
2. 不要先启动候选应用。
3. 在沙盒资源管理器地址栏输入 `%APPDATA%\com.example\mirascope` 并回车；若目录不存在则新建。
4. 将 `v1-acceptance-data` 内的全部内容复制到该目录。
5. 启动候选版 `mirascope.exe`。
6. 书架应显示“schema v1 迁移验收”；打开详情和第一章，正文应正常显示。
7. 关闭应用，确认应用数据目录中的数据库仍存在；再次启动后该书仍存在。

以上通过表示候选应用已把数据库从 `user_version = 1` 升级到 v2，并且旧记录及派生正文仍可用。

## 3. 验证整目录备份与恢复

1. 保持应用完全关闭。
2. 将 `%APPDATA%\com.example\mirascope` 整个目录复制为 `mirascope-backup`。
3. 启动应用，将“schema v1 迁移验收”归档；在提示条出现时点击“撤销”，确认作品回到书架。
4. 再次归档，进入“已归档”，点击“恢复”，确认作品回到书架；随后关闭应用。
5. 将当前 `mirascope` 目录改名为 `mirascope-after-test`，把 `mirascope-backup` 复制回原位置并命名为 `mirascope`。
6. 再次启动应用，确认作品、章节和正文仍可打开。

恢复必须覆盖数据库和 `derived_txt`，只备份 `mirascope.sqlite` 不能保证正文可读。复制前必须退出应用，以免数据库仍有未落盘内容或旁路日志文件。

## 4. 记录结果

验收记录应包含候选提交或构建物摘要、沙盒环境、执行日期，以及迁移、归档/撤销/恢复、整目录备份恢复各项结果。任何一项失败都不创建正式标签。
