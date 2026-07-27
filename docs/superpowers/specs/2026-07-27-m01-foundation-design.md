# M01 基础架构设计

## 1. 目标

本设计覆盖 MVP 0.1 的首批基础决策和应用骨架边界：

- M01-001：状态管理、路由、本地数据库和仓库结构 ADR；
- 为 M01-002 应用骨架和 M01-003 路由、主题、启动流程提供实施基线。

本设计不实现媒体库数据库表、TXT 导入或阅读器。

## 2. 技术选择

- 状态管理：Riverpod，业务 Provider 使用代码生成；
- 路由：go_router，MVP 0.1 手写路由表；
- 本地数据库：Drift + drift_flutter；
- 代码生成：统一使用 build_runner；
- 仓库结构：保留根目录 Flutter 工程；
- 模型：首期手写不可变领域类，不引入 Freezed；
- 路由：首期不引入路由代码生成。

Drift 已经需要代码生成，因此 Riverpod 使用生成器不会引入第二套生成工作流。生成文件提交到仓库，并由 CI 或本地检查确认与源文件同步。

## 3. 依赖方向

```text
Presentation
    |
    v
Application
    |
    v
Domain
    ^
    |
Data / Infrastructure
```

- Presentation 负责页面、交互和状态展示；
- Application 负责编排导入、打开、保存等用例；
- Domain 保存业务模型、规则和 Repository 接口；
- Data / Infrastructure 实现数据库、文件、编码、解析和平台能力。

Domain 不依赖 Flutter、Riverpod、go_router 或 Drift。Drift 生成类型不得直接进入 Widget。

## 4. 目录

```text
lib/
  main.dart
  src/
    app/
      app.dart
      bootstrap/
      router/
      theme/
    core/
      errors/
      logging/
      platform/
    shared/
      models/
      widgets/
    features/
      library/
        domain/
        application/
        data/
        presentation/
      novel/
        domain/
        application/
        data/
        presentation/
      settings/
        presentation/
```

MVP 0.1 不创建 `manga`、`auth`、`sync`、`server` 或 Rust 目录。只在产生真实文件时创建更深的子目录。

## 5. 状态管理边界

- Riverpod Provider 负责依赖装配和 UI 所需的同步/异步状态；
- 业务规则保存在 Domain 或 Application；
- 页面不能直接读取 Drift 数据库；
- Repository 通过 Provider 注入，测试使用覆盖替换；
- 有副作用的界面状态使用生成的类式 Notifier；
- 纯派生或只读状态使用函数式 Provider；
- 长生命周期基础设施显式 `keepAlive`，页面状态默认自动释放。

## 6. 路由

MVP 0.1 的首批路径：

```text
/library
/settings
/novel/:mediaItemId
/novel/:mediaItemId/read
```

应用启动直接进入 `/library`。暂不增加没有业务内容的首页、搜索页和“我的”页。

- 路由器只在 `src/app/router` 创建；
- feature 暴露页面及必要参数；
- 无效或缺失参数进入可恢复错误页；
- 启动错误不复用普通业务路由；
- 后续账号重定向属于 Version 0.4，不提前实现。

## 7. 启动流程

```text
main
-> WidgetsFlutterBinding.ensureInitialized
-> 初始化日志
-> 打开 Drift 数据库并运行迁移
-> 创建 ProviderScope
-> 启动 MaterialApp.router
```

数据库无法打开或迁移失败时，不进入正常媒体库，也不静默删库重建。应用显示独立启动错误页，包含稳定错误代码、重试和安全日志入口。

`main.dart` 保持最薄，实际初始化由 bootstrap 函数完成。

## 8. 数据流

媒体库读取：

```text
LibraryPage
-> libraryItemsProvider
-> WatchLibraryItems use case
-> MediaLibraryRepository
-> DriftMediaLibraryRepository
-> AppDatabase
```

后续 TXT 导入由 `ImportNovelUseCase` 协调文件选择、指纹、解码、解析、临时文件和数据库事务，不把流程塞进页面 Controller。

## 9. 错误处理与日志

错误分为：

1. 基础设施异常：SQLite、文件系统、编码库原始异常；
2. 领域错误：稳定代码和结构化上下文；
3. 展示错误：中文说明和用户可执行动作。

日志可以记录错误代码、阶段和堆栈，但不记录正文、Token 或完整敏感路径。

启动、迁移和存储错误不能被静默吞掉。Presentation 只依赖稳定错误模型，不按第三方异常文本分支。

## 10. 首批依赖

运行依赖：

```text
flutter_riverpod
riverpod_annotation
go_router
drift
drift_flutter
path_provider
logging
```

开发依赖：

```text
build_runner
riverpod_generator
riverpod_lint
custom_lint
drift_dev
```

具体兼容版本在实施时通过当前 Flutter/Dart 约束和依赖解析确定，并写入 `pubspec.lock`。不得脱离解析结果手填互不兼容的版本组合。

## 11. 测试

实施 M01-002/M01-003 时采用 TDD：

- Domain/Application：纯 Dart 单元测试；
- Drift：内存数据库测试 schema version 1、事务和约束；
- Provider：`ProviderContainer` 覆盖 Repository；
- 路由与页面：Widget 测试媒体库、设置、错误和无效参数；
- 启动：数据库成功和失败两条路径；
- 最终：格式检查、Analyze、Test、Windows Build。

M01-001 本身的完成证据是四份 ADR 均包含背景、备选、决策、后果和复核条件。

## 12. 实施边界

M01-001 只提交设计和 ADR。依赖安装、生成器配置、目录创建和默认计数器替换进入后续实施计划，不与架构决策混在同一提交。
