# mirascope 项目交接说明

> 更新时间：2026-08-15
> 已发布版本：`v0.2.0`（提交 `276472b`）
> 发布后记录：`e15c966`

## 1. 当前状态

MVP 0.2 已正式发布。Windows 与 Android 的 TXT/EPUB 导入、章节目录、阅读、设置、进度、书签、归档、重定位和删除闭环均已取得自动化或人工证据；50 MiB TXT 性能复测完成；Android 正式签名密钥已在仓库外生成并异地备份。

正式标签构建运行 `31310474175`：格式、静态分析、290 项测试、Windows release、Android debug 和 Android signed release 全部通过。GitHub Release：

`https://github.com/siokr/mirascope/releases/tag/v0.2.0`

正式发布物 SHA-256：

```text
Windows ZIP  14FE31FA42D8FB57006B8553B2B9AB6F892D1C27C87850231F656FAFFBEB4E02
Android APK  A08325AF32C125BE303C493C8A36F47EC4D9FD554AF3CA1966624800281A500B
```

## 2. 下一阶段

下一阶段是 Version 0.3 本地漫画阅读：

```text
复核输入、图片解码和许可证
→ 漫画领域模型与 schema v4
→ 目录、ZIP/CBZ 安全扫描
→ 自然排序、章节/页清单和原子导入
→ 媒体库、详情和两种阅读模式
→ 页级进度、预加载、缓存和清理
→ Windows/Android 性能与人工验收
→ v0.3.0 Release
```

`M03-001`、`M03-002`、`M03-004` 至 `M03-011` 已完成；`M03-003` 的 ZIP/CBZ 与 Windows 目录身份及重定位已实现，Android 目录因现有插件不保留 SAF URI 权限而保持进行中。漫画阅读器已具备纵向、横向单页与封面单独成屏的横向双页、页级状态、有界分层缓存、安全清理、预加载错误隔离，以及单页/整章失败和内存不足的恢复界面。85 章/891 页性能基线与 Windows/Android 人工验收已完成；Quality Gate #67 的格式、分析、381 项测试、Windows release 和 Android debug 全部通过。下一步创建候选标签、验证正式签名 APK 和发布 `v0.3.0`。在线漫画源、站点规则、下载、番剧、账号和同步不属于 0.3。

## 3. 关键风险

### Android 目录持久权限

Android 文档树不能直接等同于普通文件路径。必须先验证目录选择、重启后访问和权限撤销；现有选择器无法安全支持时，ZIP/CBZ 可先形成闭环，目录支持保持显式阻塞。

### 漫画资源预算

压缩包导入上限已冻结为：压缩包 2 GiB、20,000 条目、单条目 64 MiB、总展开量 2 GiB、压缩比 200 倍，并在实际读取时再次限制输出。图片解码与预加载仍需取消机制和独立的内存/磁盘分层预算，具体数值在后续基准后冻结。

### 既有数据与功能回归

schema v5 必须覆盖 v1/v2/v3/v4 迁移并保留小说、书签、进度和既有漫画偏好。漫画接入媒体库后，小说导航、归档、重定位、删除和发布流程不得回归。

### 仍存在的小说限制

不同指纹来源的安全原位重解析仍未实现；超大 TXT 仍缓存完整规范化文本；Windows 本机 release 工具链可能挂起，但 GitHub Actions 正式构建稳定通过。

## 4. 数据与安全约束

- 不修改、移动或删除用户原文件和目录；
- 来源丢失不删除媒体、章节、进度、设置或书签；
- 页序在导入时固化，不依赖运行时文件系统枚举顺序；
- 不安全压缩包整体拒绝，不做部分解压；
- 导入失败回滚数据库并清理临时派生文件；
- 原始来源、派生缩略图和可删除缓存严格分区；
- 清缓存不能删除媒体、进度或用户原文件；
- 日志不记录完整路径、标题、图片内容、原始异常或堆栈；
- 在线源进入项目前必须另行评审内容来源、站点条款、凭据、缓存权限和失效策略。

## 5. Git 与验证

- 当前分支：`codex/m03-local-manga`；
- 不移动或改写 `v0.1.0`、`v0.2.0-rc.1`、`v0.2.0` 标签；
- 不把 0.2 的 290 项测试数字复制为 0.3 证据；
- 生成文件只有真实 schema 或代码变化时才提交；
- 保留用户未跟踪的 `.vs/`；
- 签名密钥、密码和临时发布资产永不提交。

## 6. 建议阅读顺序

1. `plan.md`
2. `docs/m03-task-list.md`
3. `docs/manga-reader-spec.md`
4. `docs/superpowers/specs/2026-08-10-m03-local-manga-design.md`
5. `docs/data-model.md`
6. `docs/tech-architecture.md`
7. `docs/quality-strategy.md`
8. `lib/src/features/domain/`
9. `lib/src/features/importing/`
10. `lib/src/features/library/`

## 7. 一句话状态

`v0.2.0` 已正式发布；`v0.3.0-rc.1` 的本地漫画阅读、性能基线、双平台人工验收、正式签名、证书连续性、哈希与正式 APK 安装复验均已完成，Android 目录持久权限保持显式限制；下一步合并发布分支并创建 `v0.3.0` GitHub Release。
