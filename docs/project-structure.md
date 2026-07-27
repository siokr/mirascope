# mirascope 项目结构

## 1. 当前决策

当前继续使用仓库根目录的 Flutter 工程，不立即迁移到 `client/flutter_app/`。这样能减少与 MVP 0.1 无关的路径和构建调整。

只有出现以下任一条件才重新评估顶层拆分：

- Version 0.4 开始创建 Go 服务；
- 出现第二个独立客户端；
- Flutter 工程需要作为更大仓库中的独立包发布；
- 构建和 CI 已经因为根目录结构产生明确问题。

届时通过 ADR 决定是否迁移，不能把候选目录当成既定结构。

## 2. MVP 0.1 目录

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
      utils/
    shared/
      models/
      widgets/
    features/
      library/
      novel/
      settings/
test/
  app/
  core/
  features/
    library/
    novel/
docs/
assets/
```

只在实际有文件时创建子目录，不为未来模块建立空结构。

## 3. 目录职责

### `main.dart`

保持最薄，只调用启动流程。不得包含页面和业务逻辑。

### `src/app`

放应用级装配、启动、路由和主题，不放具体业务页面。

### `src/core`

放与业务无关的底层能力。小说章节规则、媒体库逻辑等不得放入 `core`。

### `src/shared`

放已经被多个 feature 复用的模型和组件。不能建立巨大的 `common.dart` 或为可能复用的代码提前抽象。

### `src/features`

按用户能力组织。MVP 0.1 只创建 `library`、`novel` 和 `settings`。

## 4. Feature 内部

根据复杂度从简开始：

```text
novel/
  domain/
  application/
  data/
  presentation/
```

- `domain`：实体扩展、规则和 Repository 接口；
- `application`：导入、阅读和恢复用例；
- `data`：数据库、文件、解析和映射实现；
- `presentation`：页面、Controller 和 feature 内组件。

如果某层只有转发且没有清晰职责，可以先不拆更深的子目录。

## 5. 测试结构

测试目录尽量镜像 `lib/src`，按被测职责命名。样例数据放在明确的 fixtures 目录，并遵守 `docs/quality-strategy.md` 的版权和隐私规则。

默认 Flutter `widget_test.dart` 在应用骨架完成后删除或替换，不能继续测试已经不存在的计数器。

## 6. 资源与文件

```text
assets/
  icons/
  images/
  fonts/
  fixtures/
```

只有运行时资源在 `pubspec.yaml` 声明。大型性能样本不直接进入资源包，除非版本确实需要。

应用运行数据不放在仓库目录。平台路径由统一服务提供，并区分原文件引用、派生数据、缓存、临时文件和日志。

## 7. 命名与依赖

- 文件和目录：`snake_case`；
- 类型：`PascalCase`；
- 变量与方法：`camelCase`；
- 一个公开类型一个主要职责；
- feature 可依赖 `core` 和 `shared`；
- feature 间交互优先通过领域接口或应用用例；
- `core` 和 `shared` 不反向依赖具体 feature。

## 8. 后续模块

- MVP 0.2：通常不新增顶层 feature，只扩展 `novel` 和平台适配；
- Version 0.3：新增 `manga`；
- Version 0.4：新增 `auth`、`sync`，并评估 `server/`；
- Rust：只有对应 ADR 接受后新增核心模块目录。

## 9. 不建议

- 所有页面直接放在 `lib/`；
- 页面同时处理文件、数据库和业务规则；
- 每个 feature 使用完全不同的结构；
- 提前创建 anime、download、server、core Rust 空目录；
- 为追求“整洁架构”增加没有行为的转发层；
- 在多个文档重复维护同一目录树。
