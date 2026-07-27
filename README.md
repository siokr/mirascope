# mirascope

`mirascope` 是一个本地优先的个人阅读与媒体管理应用。长期方向是统一管理小说、漫画和番剧；当前先把 Windows 本地 TXT 阅读做成真实可用、可测试、可公开演示的产品。

> 当前状态：项目处于规划完成、业务工程尚未启动的阶段。仓库中的 Flutter 代码仍是初始模板。下面的路线是计划，不代表对应功能已经实现。

## 当前目标：MVP 0.1

首个版本只承诺 Windows，并验证一条完整路径：

```text
导入 TXT -> 加入媒体库 -> 打开小说 -> 切换章节
-> 退出或终止应用 -> 再次启动 -> 恢复阅读位置
```

范围包括：

- Flutter 工程骨架；
- 本地媒体库和数据库迁移；
- UTF-8、UTF-16、GB18030 TXT 导入；
- 章节识别和无章节回退；
- 纵向滚动阅读器；
- 字号、行距和基础主题；
- 原子导入、重复检测、文件重新定位；
- 阅读进度持久化与恢复；
- 自动化测试、Windows 构建和演示证据。

不包括 EPUB、Android、漫画、账号同步、下载、番剧、在线内容源、Go 服务和 Rust 模块。

## 为什么这样规划

这个项目同时用于自己长期使用、求职展示和 GitHub 交流。首版优先证明：

- 产品主链路能够真正使用；
- 本地数据不会因异常轻易丢失；
- 文件导入、迁移和恢复行为能够解释和测试；
- 架构随需求演进，而不是为了展示技术栈提前堆叠。

Go、PostgreSQL 和 Rust 都有明确的进入条件，但不是当前成熟度标签。

## 路线

| 版本 | 目标 | 主要平台 |
|---|---|---|
| MVP 0.1 | 本地 TXT 小说闭环 | Windows |
| MVP 0.2 | EPUB、Android、书签和公开 Release | Windows、Android |
| Version 0.3 | 本地漫画导入与阅读 | 复用已支持平台 |
| Version 0.4 | 账号、设备和同步 | 客户端 + Go/PostgreSQL |

在线内容源、下载、番剧、其他平台和 Rust 属于后续候选方向，没有预设排期。

## 当前仓库

```text
lib/                     Flutter 初始模板，待 Phase 0 重构
docs/                    产品、架构、规格和执行文档
test/                    Flutter 默认测试，待替换
android/ ios/ ...        Flutter 生成的平台目录，不表示正式支持
plan.md                  权威版本路线
```

## 文档

建议按顺序阅读：

1. [项目计划](plan.md)
2. [MVP 执行清单](docs/mvp-task-list.md)
3. [技术架构](docs/tech-architecture.md)
4. [本地数据模型](docs/data-model.md)
5. [小说阅读规格](docs/novel-reader-spec.md)
6. [质量策略](docs/quality-strategy.md)
7. [完整文档索引](docs/README.md)

后续专题：

- [本地漫画规格](docs/manga-reader-spec.md)
- [同步协议](docs/sync-protocol.md)
- [项目结构](docs/project-structure.md)
- [开发环境](docs/dev-setup.md)
- [发布检查清单](docs/release-checklist.md)
- [架构决策记录](docs/decisions/README.md)

## 开始开发

当前 MVP 0.1 只需要 Flutter/Windows 工具链。环境要求见 [开发环境](docs/dev-setup.md)。

```bash
flutter pub get
flutter run -d windows
flutter analyze
flutter test
```

目前运行结果仍是 Flutter 默认计数器应用；完成 `M01-002` 后才会成为 mirascope 应用骨架。

## 贡献与交流

在业务开发启动前，Issue 和讨论应优先围绕明确的当前版本问题。新增需求需要说明它服务哪条核心路径、验收方式、维护成本和内容合规影响。

项目尚未发布正式贡献指南。提交代码前请先以 `plan.md` 和 `docs/mvp-task-list.md` 判断范围。
