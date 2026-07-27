# 0001 使用 Riverpod 管理状态与依赖

- 状态：accepted
- 日期：2026-07-27
- 决策者：项目维护者

## 背景

MVP 0.1 需要管理应用启动、媒体库流、异步错误、阅读器状态和 Repository 注入。方案需要支持纯 Dart 业务测试、依赖覆盖和后续模块化，同时适合单人维护。

项目接受代码生成，并将因 Drift 使用 build_runner。但当前可解析的
Riverpod 生成器与 Drift Dev 对 `analyzer` 的版本要求不兼容。

## 评估标准

- 编译期类型安全；
- 异步加载和错误表达；
- Repository 测试替换；
- 与 Flutter 生命周期配合；
- 样板代码和生成成本；
- 不迫使业务规则进入 UI 状态对象。

## 备选方案

### Riverpod 手写 Provider

支持声明式依赖、异步状态、Provider 覆盖和纯 Dart 测试。手写
Provider 会增加少量声明代码，但不与 Drift 共享 `analyzer` 构建依赖。

### Riverpod 代码生成

可减少 Provider 类型样板，但截至 2026-07-27，当前项目可解析的
Riverpod 生成器与 Drift Dev 存在 `analyzer` 版本冲突。为了保留最新
数据库和迁移工具链，不采用该组合。

### ChangeNotifier / ValueNotifier

依赖少、适合小型局部状态；项目扩大后需要手写更多依赖装配、生命周期和异步状态约定。

### Bloc / Cubit

事件和状态边界明确，测试成熟；对当前单人 MVP 会引入更多事件、状态和转发层。

## 决策

采用 Riverpod 3，并手写 Provider：

- `NotifierProvider` 处理有副作用的界面状态；
- `Provider`、`FutureProvider` 和 `StreamProvider` 处理只读或派生状态；
- 基础设施通过 Provider 注入；
- 页面级状态默认自动释放；
- 数据库等长生命周期资源显式保持。

不添加 `riverpod_annotation`、`riverpod_generator` 或 `riverpod_lint`。
build_runner 只服务 Drift。Provider 不承载领域规则，Domain 不依赖 Riverpod。

## 后果

收益：

- 依赖和异步状态具有统一模型；
- 测试可覆盖 Repository 和基础设施；
- Riverpod 不参与代码生成，避免 analyzer 依赖冲突。

代价：

- Provider 需要少量手写声明；
- 团队成员需要理解 Provider 生命周期；
- Drift 生成流程仍需维护。

## 复核条件

如果未来 Riverpod 与 Drift 生成器的 analyzer 约束兼容，并且手写 Provider
已产生可测量的维护问题，可以通过新 ADR 重新评估代码生成。大量业务逻辑
依赖 Riverpod 类型时应先修正分层，而不是更换状态管理库。
