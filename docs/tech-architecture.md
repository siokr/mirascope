# mirascope 技术架构设计文档

## 1. 文档目标

这份文档用于明确 `mirascope` 的技术分层、模块边界和演进路线，避免后续开发中出现职责混乱、重复造轮子和过早复杂化。

---

## 2. 设计原则

### 2.1 本地优先

核心阅读和观看能力必须在离线或弱网环境下仍然可用。

### 2.2 统一模型优先

小说、漫画、番剧在表现层不同，但在媒体库、收藏、历史、同步上尽量使用统一抽象。

### 2.3 先简单后下沉

能在 Flutter/Dart 完成的能力，优先不下沉到 Rust。只有性能瓶颈明确存在时，再拆分到 Rust 核心模块。

### 2.4 同步是增强，不是依赖

同步系统应当建立在本地数据正确、可恢复、可追踪的基础之上。

### 2.5 模块边界清晰

客户端、服务端、核心引擎的数据流与责任要清晰，避免“哪里都能写一点逻辑”。

---

## 3. 总体架构

```text
Flutter Client
  -> Presentation Layer
  -> Application Layer
  -> Domain Layer
  -> Data Layer
       -> Local Database
       -> Remote API
       -> File System
       -> Optional Rust FFI

Go Server
  -> REST API
  -> Auth Module
  -> Sync Module
  -> User Module
  -> Metadata / Source Adapter
  -> PostgreSQL

Rust Core (optional, incremental)
  -> Parser Engine
  -> Download Engine
  -> Image Processing
  -> Crypto / Validation
```

---

## 4. 客户端架构

客户端建议采用分层 + 按模块组织的结构。

### 4.1 推荐目录结构

```text
lib/
  main.dart
  src/
    app/
      app.dart
      router/
      theme/
      bootstrap/
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
      widgets/
      models/
      services/
```

### 4.2 分层职责

#### Presentation Layer

负责：

- 页面
- 组件
- 状态展示
- 用户交互

不负责：

- 直接操作数据库
- 直接拼接复杂业务逻辑

#### Application Layer

负责：

- 用例编排
- 页面状态驱动
- 调用 Repository
- 组合多个服务完成单个用户动作

例如：

- 打开一本小说
- 保存阅读进度
- 登录并触发首次同步

#### Domain Layer

负责：

- 核心业务模型
- 业务规则
- 抽象接口

典型对象：

- `MediaItem`
- `LibraryEntry`
- `ProgressRecord`
- `Bookmark`
- `SyncTask`

#### Data Layer

负责：

- 本地数据库访问
- 远程接口请求
- 文件系统读写
- 数据映射与缓存

---

## 5. 客户端核心模块设计

### 5.1 App 基础模块

负责：

- 启动流程
- 路由
- 全局主题
- 全局错误处理
- 依赖注入

建议：

- 使用 `go_router` 管理导航
- 使用 `Riverpod` 管理状态与依赖

### 5.2 Library 模块

负责：

- 统一书架/媒体库
- 收藏管理
- 最近阅读/观看
- 统一搜索入口承接

这是整个产品最重要的中枢模块之一。

### 5.3 Novel 模块

负责：

- 文件导入
- 章节解析
- 阅读器
- 书签和进度管理

### 5.4 Manga 模块

负责：

- 漫画源接入
- 搜索与详情
- 章节图片加载
- 漫画阅读器

### 5.5 Anime 模块

负责：

- 番剧搜索与详情
- 分集管理
- 视频播放页
- 字幕与历史

### 5.6 Auth 模块

负责：

- 登录注册
- Token 生命周期管理
- 登录态持久化

### 5.7 Sync 模块

负责：

- 同步任务调度
- 上行/下行同步
- 冲突处理
- 同步状态展示

### 5.8 Settings 模块

负责：

- 主题设置
- 阅读偏好
- 缓存管理
- 账号设置

---

## 6. 状态管理与数据流

### 6.1 状态管理建议

推荐使用 `Riverpod`，原因：

- 依赖注入能力清晰
- 方便按模块拆 Provider
- 测试友好
- 比较适合中大型 Flutter 项目演进

### 6.2 数据流原则

建议统一采用：

`UI -> Provider / Controller -> UseCase / Service -> Repository -> DataSource`

这样做的好处：

- 页面层更轻
- 业务逻辑可测试
- 本地与远程数据源可替换

---

## 7. 本地数据层设计

### 7.1 本地数据库选择

推荐优先：

- `Drift`：适合关系清晰、可迁移、可查询的数据结构

备选：

- `Isar`：开发体验较好，但如果后期需要复杂关系查询，要提前评估

对于 `mirascope` 这种存在：

- 收藏
- 历史
- 多类型媒体
- 同步状态
- 下载记录

更建议优先选 `Drift`。

### 7.2 本地核心表

建议至少包含：

- `media_items`
- `library_entries`
- `progress_records`
- `bookmarks`
- `settings`
- `sync_snapshots`
- `download_tasks`

### 7.3 本地优先策略

所有用户操作先写本地，再按策略同步到云端。

例如：

- 收藏一本漫画 -> 先写本地 -> 标记待同步
- 更新小说进度 -> 先写本地 -> 后台同步

这样即使同步失败，也不会影响主流程体验。

---

## 8. 文件系统设计

### 8.1 本地文件类型

- 小说原文件
- 章节缓存
- 漫画图片缓存
- 视频缓存
- 封面缓存
- 日志文件

### 8.2 目录建议

```text
app_data/
  novels/
  manga_cache/
  video_cache/
  covers/
  temp/
  logs/
```

### 8.3 原则

- 文件路径管理统一封装
- 缓存与用户导入文件区分开
- 支持缓存清理与空间统计

---

## 9. 服务端架构

### 9.1 服务端职责

Go 服务端首期只做必要能力：

- 用户管理
- 鉴权
- 收藏/历史/设置同步
- 设备管理

不建议首期承担：

- 重推荐系统
- 复杂内容采集中心
- 大型社区逻辑

### 9.2 推荐目录结构

```text
server/
  golang_api/
    cmd/
    internal/
      auth/
      user/
      sync/
      library/
      settings/
      platform/
      storage/
      transport/
    migrations/
```

### 9.3 服务端模块

#### Auth

- 注册
- 登录
- Token 签发
- Token 刷新

#### User

- 用户资料
- 设备绑定
- 账号基础配置

#### Sync

- 收藏同步
- 进度同步
- 设置同步
- 冲突处理

#### Library

- 云端媒体库镜像
- 收藏列表接口
- 历史列表接口

---

## 10. 服务端数据库设计

建议的核心表：

- `users`
- `devices`
- `media_items`
- `library_entries`
- `progress_records`
- `bookmarks`
- `user_settings`
- `sync_events`

说明：

- 服务端的 `media_items` 可以先只存业务必要字段，不一定一开始就做成完整内容中心
- 同步系统需要保留更新时间与来源设备信息，方便冲突处理

---

## 11. 同步系统设计

### 11.1 同步目标

首期同步范围：

- 收藏
- 小说阅读进度
- 漫画阅读进度
- 书签
- 设置

### 11.2 同步原则

- 本地先写
- 云端最终一致
- 同步失败可重试
- 冲突可解释

### 11.3 冲突策略建议

首期使用简单可控策略：

- 以 `updated_at` 为主
- 必要时保留本地快照
- 同步冲突时提示用户可恢复

### 11.4 同步触发时机

- 用户登录后
- 应用启动后
- 进入前台后
- 用户主动点击同步时
- 关键数据变更后后台节流同步

---

## 12. Rust 核心模块设计

Rust 不应一开始包揽太多逻辑，而应作为可插拔高性能能力层。

### 12.1 适合放到 Rust 的能力

- EPUB/TXT 复杂解析
- 高性能下载调度
- 漫画图片解码或处理
- 文件校验
- 加密与签名工具

### 12.2 不建议过早放到 Rust 的能力

- 普通 UI 业务逻辑
- 简单收藏/历史逻辑
- 同步流程编排

### 12.3 接入方式

建议通过 FFI 暴露少量稳定接口，例如：

- `parseBook(filePath)`
- `startDownload(taskConfig)`
- `verifyFile(filePath)`

原则：

- API 小而稳定
- 输入输出结构清晰
- 不把 Flutter 页面逻辑耦合进 Rust

---

## 13. 网络层设计

### 13.1 客户端网络层职责

- 请求封装
- 统一鉴权头注入
- 错误映射
- 重试策略
- 日志记录

### 13.2 API 设计原则

- REST 风格优先
- 接口命名稳定
- 响应结构统一
- 错误码语义明确

### 13.3 建议的首期 API 范围

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `GET /me`
- `GET /sync/state`
- `POST /sync/library`
- `POST /sync/progress`
- `POST /sync/settings`

---

## 14. 可观测性与错误处理

### 14.1 客户端

建议具备：

- 页面级错误提示
- 本地日志
- 崩溃记录
- 同步失败追踪

### 14.2 服务端

建议具备：

- 请求日志
- 错误日志
- 登录与同步关键事件日志
- 健康检查接口

### 14.3 原则

- 重要错误必须可定位
- 用户无感错误也要能追踪
- 不把异常静默吞掉

---

## 15. 安全设计

首期重点：

- Token 安全存储
- HTTPS 传输
- 基础限流
- 最小化存储敏感信息
- 本地用户数据合理隔离

不建议首期就追求过重安全体系，但登录态和同步数据必须认真处理。

---

## 16. 测试策略

### 16.1 客户端

- Domain / Repository 单元测试
- 核心阅读器状态测试
- 路由与页面基础测试

### 16.2 服务端

- API 接口测试
- 数据库访问测试
- 鉴权测试
- 同步冲突测试

### 16.3 重点测试场景

- 小说大文件导入
- 漫画大章节加载
- 断网恢复
- 多设备同步冲突
- 退出重进后进度恢复

---

## 17. 演进路线

### 阶段 1

Flutter 单体客户端，先完成本地阅读与媒体库。

### 阶段 2

Go 服务端加入，完成账号与基础同步。

### 阶段 3

Rust 下沉高性能模块，补下载、解析、图片处理。

### 阶段 4

扩展番剧、搜索增强、可观测性与 Beta 级运维能力。

---

## 18. 当前推荐技术选型

客户端：

- Flutter
- Dart
- Riverpod
- go_router
- Dio
- Drift

服务端：

- Go
- PostgreSQL
- JWT 或等价 Token 方案

核心模块：

- Rust

可选增强：

- Meilisearch
- FFmpeg

---

## 19. 一句话架构结论

`mirascope` 最适合走“Flutter 本地优先 + Go 轻后端同步 + Rust 渐进式性能下沉”的路线，而不是一开始做成重后端、重服务、重分布式平台。
