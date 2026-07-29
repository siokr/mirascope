# mirascope 文档索引

## 1. 文档体系

### 项目入口

- [`../README.md`](../README.md)：面向 GitHub 访问者的真实状态、当前目标和快速入口。
- [`../plan.md`](../plan.md)：版本范围、平台策略、成功标准和风险的单一信息源。

### 当前执行

- [`mvp-task-list.md`](mvp-task-list.md)：当前版本任务、依赖、状态、交付物和验收。
- [`quality-strategy.md`](quality-strategy.md)：测试层级、质量门槛和性能基准方法。
- [`release-checklist.md`](release-checklist.md)：候选版本与 GitHub Release 检查。
- [`demo-guide.md`](demo-guide.md)：MVP 0.1 核心演示路径和记录要求。
- [`known-issues.md`](known-issues.md)：当前限制、影响与处理计划。
- [`releases/0.1.0-rc.1.md`](releases/0.1.0-rc.1.md)：首个候选版本的真实检查状态。

### 架构与工程

- [`tech-architecture.md`](tech-architecture.md)：系统边界、依赖方向和阶段演进。
- [`project-structure.md`](project-structure.md)：当前代码组织和未来拆分触发条件。
- [`dev-setup.md`](dev-setup.md)：可复现开发环境和检查命令。
- [`decisions/README.md`](decisions/README.md)：ADR 格式、状态和首批决策。

### 领域规格

- [`data-model.md`](data-model.md)：本地实体、关系、迁移和文件生命周期。
- [`novel-reader-spec.md`](novel-reader-spec.md)：TXT/EPUB 导入与小说阅读行为。
- [`manga-reader-spec.md`](manga-reader-spec.md)：Version 0.3 本地漫画边界。
- [`sync-protocol.md`](sync-protocol.md)：Version 0.4 同步语义。

### 设计与实施记录

- [`superpowers/specs/2026-07-26-documentation-restructure-design.md`](superpowers/specs/2026-07-26-documentation-restructure-design.md)：本轮文档重构设计。
- [`superpowers/plans/2026-07-26-documentation-restructure.md`](superpowers/plans/2026-07-26-documentation-restructure.md)：本轮实施计划。

Flutter 生成的 `ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md` 是平台资源说明，不属于项目规划文档。

## 2. 推荐阅读顺序

### 了解项目

1. 根 README；
2. `plan.md`；
3. `mvp-task-list.md`。

### 开始 MVP 0.1

1. `dev-setup.md`；
2. `tech-architecture.md`；
3. `project-structure.md`；
4. `data-model.md`；
5. `novel-reader-spec.md`；
6. `quality-strategy.md`。

### 准备后续版本

- Version 0.3 开始前复核漫画规格；
- Version 0.4 开始前复核同步协议；
- 每次发布使用发布检查清单。

## 3. 单一信息源

| 信息 | 权威文件 |
|---|---|
| 版本包含与排除范围 | `plan.md` |
| 当前任务和状态 | `mvp-task-list.md` |
| 本地实体和字段语义 | `data-model.md` |
| 小说导入与阅读行为 | `novel-reader-spec.md` |
| 本地漫画行为 | `manga-reader-spec.md` |
| 同步语义 | `sync-protocol.md` |
| 质量门槛 | `quality-strategy.md` |
| 目录职责 | `project-structure.md` |
| 技术选择原因 | `decisions/` 中的 ADR |

其他文件应使用链接和摘要，不复制整套定义。

## 4. 状态表达

- **已实现**：代码、测试或发布物存在，且取得验证证据；
- **开发中**：任务状态为 `in_progress`；
- **计划**：已经进入版本范围，但尚未完成；
- **候选**：尚未进入正式版本范围。

README 和 Release 不能把计划或候选能力写成已经支持。

## 5. 更新触发条件

- 版本范围变化：先更新 `plan.md`，再调整任务和专题规格；
- 开始或完成任务：只更新 `mvp-task-list.md` 的对应状态和证据；
- 领域语义变化：更新对应专题规格并检查迁移；
- 技术选择变化：新增或替代 ADR；
- 支持平台变化：更新计划、环境、质量和发布文档；
- 发布版本：检查 README、已知问题、质量证据和所有链接。

## 6. 写作规则

- 使用具体行为和可验证条件，避免“体验良好”“基本稳定”；
- 不写没有测量依据的性能数字；
- 环境快照必须有日期和命令；
- 不保留未解释的占位内容；
- 未实现能力明确标为计划；
- 变更文档时检查链接和跨文档版本边界。
