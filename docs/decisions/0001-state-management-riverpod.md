# 0001 使用 Riverpod 管理状态与依赖

- 状态：accepted
- 日期：2026-07-27
- 决策者：项目维护者

## 背景

MVP 0.1 需要管理应用启动、媒体库流、异步错误、阅读器状态和 Repository 注入。方案需要支持纯 Dart 业务测试、依赖覆盖和后续模块化，同时适合单人维护。

项目已接受代码生成，并将因 Drift 使用 build_runner。

## 评估标准

- 编译期类型安全；
- 异步加载和错误表达；
- Repository 测试替换；
- 与 Flutter 生命周期配合；
- 样板代码和生成成本；
- 不迫使业务规则进入 UI 状态对象。

## 备选方案

### Riverpod

支持声明式依赖、异步状态、Provider 覆盖和纯 Dart 测试。代码生成可减少 Provider 类型样板，但需要维护生成步骤。

### ChangeNotifier / ValueNotifier

依赖少、适合小型局部状态；项目扩大后需要手写更多依赖装配、生命周期和异步状态约定。

### Bloc / Cubit

事件和状态边界明确，测试成熟；对当前单人 MVP 会引入更多事件、状态和转发层。

## 决策

采用 Riverpod。业务 Provider 默认使用 `riverpod_annotation` 与生成器：

- 类式 Notifier 处理有副作用的界面状态；
- 函数式 Provider 处理只读或派生状态；
- 基础设施通过 Provider 注入；
- 页面级状态默认自动释放；
- 数据库等长生命周期资源显式保持。

Provider 不承载领域规则，Domain 不依赖 Riverpod。

## 后果

收益：

- 依赖和异步状态具有统一模型；
- 测试可覆盖 Repository 和基础设施；
- 与已有 build_runner 工作流复用。

代价：

- 需要提交并检查生成文件；
- 团队成员需要理解 Provider 生命周期；
- 生成配置错误可能影响开发体验。

## 复核条件

如果生成耗时明显阻塞日常开发，或大量业务逻辑被迫依赖 Riverpod 类型，应复核使用方式，而不是立即更换状态管理库。
