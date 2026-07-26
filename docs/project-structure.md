# mirascope 项目目录结构说明

这份文档用于把 `mirascope` 的目录结构、模块边界和落地规则写清楚，避免 Phase 0 开始改代码时一边写一边改目录，最后越堆越乱。

---

## 1. 文档目标

这份文档主要回答三个问题：

- 仓库应该怎么分层
- Flutter 客户端内部应该怎么拆目录
- 每个目录该放什么、不该放什么

它是 `docs/tech-architecture.md` 的落地版，偏“怎么组织代码”，不重复讲太多产品规划内容。

---

## 2. 结构设计原则

目录设计遵循以下原则：

- 先按职责分层，再按业务模块拆分
- 公共能力集中收口，不要散落在各个页面里
- 核心业务以 `feature` 为边界组织
- 先服务 MVP，不为了“未来可能会有的大系统”过度设计
- 一眼能看懂每层职责，减少“这个文件到底该放哪”的犹豫

---

## 3. 仓库级目录结构

`mirascope` 最终建议演进为下面这套仓库结构：

```text
mirascope/
  client/
    flutter_app/
  server/
    golang_api/
  core/
    rust_engine/
  database/
    migrations/
  docs/
  scripts/
  assets/
```

### 各目录职责

#### `client/`

存放客户端代码。

当前阶段核心是 Flutter App，后面如果要拆多客户端，也继续放在这里。

#### `server/`

存放 Go 后端服务代码。

首期只负责账号、同步、设置等必要后端能力。

#### `core/`

存放 Rust 高性能模块。

只承接解析、下载、图片处理、校验等明确需要高性能的能力。

#### `database/`

存放数据库迁移、初始化 SQL、种子数据等。

#### `docs/`

存放产品、架构、执行、环境、接口等所有文档。

#### `scripts/`

存放开发辅助脚本，例如：

- 初始化脚本
- 构建脚本
- 本地启动脚本
- 代码生成脚本

#### `assets/`

存放图片、图标、字体、占位资源等公共静态资源。

---

## 4. 当前阶段的现实落地方式

因为当前仓库是 Flutter 默认初始化工程，短期内不一定立刻重构成 `client/flutter_app` 这种顶层结构。

所以建议分两步走：

### 第一步：先在当前仓库根目录内完成 Flutter 内部分层

也就是先把现在的 Flutter 项目整理好，重点改：

- `lib/`
- `test/`
- `assets/`
- `docs/`

### 第二步：等客户端结构稳定后，再决定是否整体迁移到 `client/flutter_app/`

这样更稳，不会在项目还没开始时就把目录搬来搬去。

---

## 5. Flutter 客户端推荐结构

当前阶段建议采用下面这套结构：

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
      constants/
      errors/
      logging/
      network/
      storage/
      utils/
    features/
      library/
      novel/
      manga/
      anime/
      auth/
      sync/
      settings/
    shared/
      models/
      services/
      widgets/
```

这是当前最适合 `mirascope` 的客户端结构：既比默认 Flutter 工程清晰很多，又不会复杂到一开始就维护吃力。

---

## 6. `lib/` 分层说明

### 6.1 `main.dart`

职责：

- 应用入口
- 调用启动流程
- 尽量只保留最薄的一层入口代码

不建议：

- 在这里直接写页面逻辑
- 在这里直接初始化大量业务代码

### 6.2 `src/app/`

职责：应用级配置和总装配层。

建议包含：

- `app.dart`：根 App Widget
- `bootstrap/`：启动初始化逻辑
- `router/`：路由配置
- `theme/`：主题配置

适合放：

- 全局路由表
- 启动顺序
- 全局 Provider 装配
- 主题和应用壳层

不适合放：

- 具体某个业务页面的大量实现

### 6.3 `src/core/`

职责：全项目共享的底层基础能力。

建议子目录：

- `constants/`
- `errors/`
- `logging/`
- `network/`
- `storage/`
- `utils/`

适合放：

- 常量定义
- 通用异常类型
- 日志封装
- Dio 基础封装
- 本地存储底层适配
- 与业务无关的工具函数

不适合放：

- 小说阅读器状态
- 漫画章节逻辑
- 任何强业务语义代码

### 6.4 `src/features/`

职责：按业务模块拆分代码，是项目最主要的实现区域。

当前建议模块：

- `library/`
- `novel/`
- `manga/`
- `anime/`
- `auth/`
- `sync/`
- `settings/`

每个 feature 可以继续拆自己的页面、状态、数据和组件。

### 6.5 `src/shared/`

职责：介于业务和基础设施之间的可复用层。

建议放：

- 通用 UI 组件
- 多模块共享的数据模型
- 跨模块共享服务

适合放：

- 公共卡片组件
- 通用空状态组件
- `MediaItem` 这种多模块共享模型

不适合放：

- 某个单独模块的私有实现

---

## 7. feature 内部推荐结构

每个业务模块建议尽量保持一致的内部结构，例如：

```text
features/
  novel/
    data/
    domain/
    presentation/
    widgets/
```

或者更细一点：

```text
features/
  novel/
    data/
      datasources/
      models/
      repositories/
    domain/
      entities/
      repositories/
      usecases/
    presentation/
      controllers/
      pages/
      states/
    widgets/
```

### 为什么这样拆

- `data/` 负责数据来源和映射
- `domain/` 负责业务规则和抽象
- `presentation/` 负责页面与状态
- `widgets/` 负责模块内复用组件

这样做的好处是：后面小说、漫画、番剧都能用同一思路组织，不会每个模块各写各的。

---

## 8. MVP 阶段建议优先落地的目录

为了避免一开始建一堆空目录，建议分阶段创建。

### Phase 0 必建

```text
lib/
  main.dart
  src/
    app/
    core/
    features/
    shared/
```

### Phase 1 建议补齐

```text
lib/src/features/
  library/
  settings/
  novel/
```

### Phase 2 再补

```text
lib/src/features/
  manga/
  auth/
  sync/
```

### Phase 3 以后再加

```text
lib/src/features/
  anime/
```

这样更符合“边开发边收敛”的节奏。

---

## 9. 测试目录建议

建议不要把所有测试都堆在 `widget_test.dart` 里。

推荐结构：

```text
test/
  app/
  core/
  features/
    novel/
    manga/
    auth/
```

原则：

- 测试目录尽量镜像 `lib/src/` 的结构
- 哪个模块的代码，就尽量对应哪个模块的测试

---

## 10. 资源目录建议

推荐在根目录增加：

```text
assets/
  icons/
  images/
  fonts/
  placeholders/
```

适合放：

- App 图标
- 默认封面
- 空状态插图
- 自定义字体

后续需要在 `pubspec.yaml` 中统一声明。

---

## 11. 命名约定

建议统一以下规则：

- 文件名使用 `snake_case`
- 目录名使用 `snake_case`
- 类名使用 `PascalCase`
- Provider / Controller / Repository 按职责直命名

例如：

- `library_page.dart`
- `novel_reader_page.dart`
- `app_router.dart`
- `media_item.dart`

不建议：

- 同一类职责出现多套命名风格
- 页面、状态、控制器命名混乱

---

## 12. 不建议的做法

为了避免项目后期变乱，当前阶段尽量不要这样做：

- 所有页面都直接放在 `lib/` 根下
- 把网络、存储、业务逻辑直接写进页面
- 先建大量永远用不到的空模块
- 把所有共享组件都塞进一个巨大的 `common.dart`
- 每个 feature 用完全不同的目录风格

---

## 13. 推荐落地顺序

如果下一步开始改代码，建议按这个顺序落：

1. 新建 `lib/src/app`
2. 新建 `lib/src/core`
3. 新建 `lib/src/shared`
4. 新建 `lib/src/features/library`
5. 新建 `lib/src/features/settings`
6. 替换 `main.dart` 默认模板
7. 再逐步加入 `novel`、`manga` 等模块

---

## 14. 一句话结论

`mirascope` 当前最合适的代码组织方式，是“仓库层面先稳住当前 Flutter 工程，客户端内部先完成 `app + core + features + shared` 分层，再随着 MVP 推进逐步扩展到后端和 Rust 模块”。
