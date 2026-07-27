# mirascope 技术架构

## 1. 文档职责

本文定义系统边界、依赖方向和阶段演进，不重复版本范围、数据字段或同步协议。版本以 `plan.md` 为准，实体以 `docs/data-model.md` 为准。

## 2. 核心原则

- 本地阅读不依赖账号或网络；
- 依赖由界面和用例指向领域抽象，基础设施实现抽象；
- 数据库状态、用户原文件、派生数据和缓存分开管理；
- 先用 Dart 完成并测量，再决定是否下沉 Rust；
- 只为当前版本创建模块，避免空架构；
- 错误可解释，关键写入可恢复。

## 3. MVP 0.1 客户端架构

```text
Flutter UI
  -> Controller / Notifier
  -> Use Case
  -> Domain Repository Interface
  -> Repository Implementation
       -> Local Database
       -> File System
       -> Parser
```

### Presentation

负责页面、组件、交互和状态展示，不直接访问数据库或解析文件。

### Application

负责用例编排，例如导入 TXT、打开小说、保存进度和重新定位文件。跨数据库与文件系统的补偿和回滚在这一层协调。

### Domain

保存稳定实体、规则和 Repository 接口，不依赖 Flutter Widget、具体数据库或文件选择库。

### Data / Infrastructure

实现数据库、文件系统、编码、章节解析、日志和平台适配。基础设施错误需要映射为稳定领域错误。

## 4. 关键数据流

### 4.1 导入

```text
File Picker
-> Import Use Case
-> File Validation / Fingerprint
-> Decode / Parse
-> Temporary Derived Data
-> Database Transaction
-> Atomic Finalization
-> Library Refresh
```

失败时数据库回滚并清理未引用临时文件。行为以小说规格为准。

### 4.2 阅读和进度

```text
Reader UI
-> Reader Controller
-> Content Repository
-> Rendered Content

Semantic Position
-> Debounced Progress Use Case
-> Revision Check
-> Local Database
```

界面不持有唯一进度副本；像素滚动位置不作为持久化身份。

## 5. 模块边界

### `app`

应用启动、全局依赖装配、路由、主题和顶层错误边界。

### `core`

无业务语义的日志、错误基类、平台路径、时间和基础工具。不能成为任意代码的收容目录。

### `shared`

被多个业务模块复用的领域实体和 UI 组件。共享以已有两个以上调用者为依据。

### `library`

媒体库、归档、收藏和最近打开。依赖统一媒体抽象，不包含 TXT 解码和漫画图片处理。

### `novel`

小说导入、章节解析、详情、目录、阅读器和进度定位。

后续 `manga`、`auth`、`sync` 仅在对应版本开始时创建。

## 6. 状态管理、路由和数据库

候选方向仍为 Riverpod、go_router 和 Drift，但正式采用前分别建立 ADR。ADR 必须比较备选方案、测试方式、代码生成、迁移和平台成本。

专题文档可以使用稳定领域名称，不得把候选库的 API 写成已经确定的公共接口。

## 7. 错误与可观测性

- 用户看到可操作的错误说明；
- 日志使用稳定错误代码、阶段、请求或操作 ID；
- 不记录正文、图片、Token 和完整敏感路径；
- 导入、迁移和进度写入失败必须能够定位；
- 可预期错误不通过静默 catch 吞掉；
- 发布版本提供安全的日志导出方式。

## 8. 阶段演进

### MVP 0.1

Flutter 单体、本地数据库和本地文件系统。没有服务端或 Rust 依赖。

### MVP 0.2

增加 Android 平台适配和 EPUB 解析，保持相同领域与 Repository 边界。

### Version 0.3

增加 `manga` 模块、图片解码和缓存基础设施，复用媒体库与进度抽象。

### Version 0.4

增加 Go 服务、PostgreSQL、远程 Repository 和同步队列。UI 继续读取本地状态，同步在后台合并，协议以 `docs/sync-protocol.md` 为准。

### Rust 触发条件

只有性能基准、Dart 优化记录和维护成本评估同时成立时，才通过 ADR 定义小而稳定的 FFI 接口。

## 9. 测试边界

- Domain：纯单元测试；
- Application：使用假 Repository 测用例和错误补偿；
- Data：使用临时数据库和文件目录做集成测试；
- Presentation：Widget 测试关键状态；
- 支持平台：构建检查和核心路径手工验证。

具体门槛以 `docs/quality-strategy.md` 为准。

## 10. 架构禁止项

- 页面直接执行 SQL 或文件解析；
- 用 `updatedAt` 单独决定跨设备冲突；
- 为远期模块提前建立空服务和空目录；
- 在没有基准时引入 FFI；
- 缓存清理删除用户原文件或领域状态；
- 将未接受的候选技术写成既成事实。
