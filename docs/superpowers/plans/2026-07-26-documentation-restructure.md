# mirascope Documentation Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将现有项目文档重构成范围一致、可执行、可量化验收，并适合个人长期开发与 GitHub 求职展示的文档体系。

**Architecture:** `plan.md` 作为版本范围的单一信息源，`docs/mvp-task-list.md` 只管理当前执行任务，专题规格分别承载数据、阅读器、同步、质量和发布规则。先建立权威专题文档，再回写入口文档和总览，最后通过自动检查与人工对照消除重复、失效链接和版本冲突。

**Tech Stack:** Markdown、Git、PowerShell 文档检查命令。

## Global Constraints

- 本次只修改文档，不修改 Flutter、Go 或 Rust 代码。
- MVP 0.1 主平台为 Windows，核心闭环为本地 TXT 阅读。
- MVP 0.2 增加 Android、EPUB 和公开展示材料。
- Version 0.3 聚焦本地漫画，不包含在线漫画源。
- Version 0.4 才引入 Go、PostgreSQL、账号和同步。
- 下载、番剧、在线内容源和 Rust 不属于早期 MVP 必做范围。
- Rust 仅在性能基准证明 Dart 无法满足已定义指标时引入。
- 不伪造尚未执行的性能数据、测试结果或环境状态。
- 文档不保留 `TBD`、`TODO` 或未解释的占位内容。

---

## File Responsibility Map

### 修改

- `README.md`：面向访问者的项目入口、真实状态、路线摘要和导航。
- `plan.md`：唯一的产品范围、版本路线、成功指标和风险基线。
- `docs/README.md`：文档索引、权威关系和维护规则。
- `docs/mvp-task-list.md`：MVP 0.1 详细任务以及后续版本进入条件。
- `docs/tech-architecture.md`：系统边界、阶段演进、数据流和架构约束。
- `docs/project-structure.md`：当前 Flutter 单体目录方案及未来拆仓触发条件。
- `docs/dev-setup.md`：可复现的开发环境要求和检查命令。

### 新增

- `docs/data-model.md`：本地数据实体、关系、约束、迁移和文件生命周期。
- `docs/novel-reader-spec.md`：TXT/EPUB 导入与小说阅读器行为规格。
- `docs/manga-reader-spec.md`：本地漫画导入、缓存和阅读器规格。
- `docs/sync-protocol.md`：Version 0.4 的同步协议设计。
- `docs/quality-strategy.md`：测试层级、平台矩阵和质量门槛。
- `docs/release-checklist.md`：MVP 演示包和 GitHub Release 检查表。
- `docs/decisions/README.md`：ADR 文件格式、状态和命名规则。

### 保留但不纳入项目规划

- `ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md`：Flutter/iOS 生成的资源说明，不参与产品计划维护。

---

### Task 1: 建立版本范围的单一信息源

**Files:**

- Modify: `plan.md`

**Interfaces:**

- Consumes: `docs/superpowers/specs/2026-07-26-documentation-restructure-design.md`
- Produces: MVP 0.1、MVP 0.2、Version 0.3、Version 0.4 的权威范围和阶段门槛，供其余文档引用。

- [ ] **Step 1: 重写项目目标和用户价值**

保留“统一二次元内容入口”的长期愿景，明确近期项目首先证明本地阅读体验、工程质量和可持续演进，不以技术栈数量作为目标。

- [ ] **Step 2: 写入四阶段版本基线**

逐阶段列出目标、包含范围、明确排除项、核心演示路径和完成标准。删除原有按 12 个月线性覆盖小说、漫画、同步、番剧、下载的承诺。

- [ ] **Step 3: 统一优先级和平台策略**

执行顺序固定为：

```text
工程骨架 -> 本地数据与媒体库 -> TXT 小说 -> EPUB/Android -> 本地漫画 -> 账号与同步
```

平台顺序固定为 Windows、Android，其他平台只保留为长期目标。

- [ ] **Step 4: 补充成功指标和风险**

增加真实使用、GitHub 展示、工程质量、内容合规、单人维护、文档失真和范围膨胀的判断标准及应对。

- [ ] **Step 5: 检查总计划内部一致性**

Run:

```powershell
Select-String -Path plan.md -Pattern '第 [0-9]+ 个月|12 个月|首期必须.*下载|全平台'
```

Expected: 不出现旧的固定月份承诺、早期下载必做或全平台首发承诺。

- [ ] **Step 6: 提交版本基线**

```bash
git add plan.md
git commit -m "docs: establish focused product roadmap"
```

### Task 2: 定义本地数据和小说阅读规格

**Files:**

- Create: `docs/data-model.md`
- Create: `docs/novel-reader-spec.md`

**Interfaces:**

- Consumes: `plan.md` 的 MVP 0.1 与 MVP 0.2 范围。
- Produces: 媒体库与小说实现使用的实体语义、文件生命周期、导入行为和验收标准。

- [ ] **Step 1: 编写数据模型职责和关系**

定义 `MediaItem`、`LibraryEntry`、`ContentUnit`、`ReadingProgress`、`Bookmark`、`ReaderPreference`、`ImportRecord` 的身份、关系和所有权。明确共享字段与媒介专属扩展的边界。

- [ ] **Step 2: 定义约束与生命周期**

写清 ID 策略、重复导入、文件指纹、原文件移动或丢失、软删除、物理删除、缓存清理、索引和迁移规则。

- [ ] **Step 3: 编写 TXT 导入规格**

覆盖文件选择、编码识别、章节识别、元数据生成、重复判断、错误反馈和导入回滚。编码范围明确为 UTF-8、UTF-16 和 GB18030；识别失败时提示用户选择编码。

- [ ] **Step 4: 编写阅读状态规格**

定义当前位置、章节、偏移量、进度写入时机、异常终止恢复、书签和阅读设置的持久化规则。

- [ ] **Step 5: 编写 EPUB 边界**

EPUB 明确属于 MVP 0.2；定义基础兼容范围、容器损坏、目录缺失、资源缺失和不支持能力的处理，不将 EPUB 误写为 MVP 0.1 前置条件。

- [ ] **Step 6: 写入可验证验收场景**

每份规格包含正常、异常、重复导入、文件丢失和恢复场景；性能指标先规定测量方法和记录格式，不伪造阈值。

- [ ] **Step 7: 检查跨文档实体名称**

Run:

```powershell
Select-String -Path docs/data-model.md,docs/novel-reader-spec.md -Pattern 'MediaItem|LibraryEntry|ContentUnit|ReadingProgress|Bookmark|ReaderPreference|ImportRecord'
```

Expected: 数据模型文档定义全部七个实体，小说规格只引用这些已定义名称。

- [ ] **Step 8: 提交本地核心规格**

```bash
git add docs/data-model.md docs/novel-reader-spec.md
git commit -m "docs: specify local data and novel reading"
```

### Task 3: 定义后续漫画与同步边界

**Files:**

- Create: `docs/manga-reader-spec.md`
- Create: `docs/sync-protocol.md`

**Interfaces:**

- Consumes: `plan.md` 的 Version 0.3 和 Version 0.4 范围、`docs/data-model.md` 的实体语义。
- Produces: 后续版本的进入条件与技术协议，避免早期实现时预埋错误假设。

- [ ] **Step 1: 编写本地漫画输入范围**

支持范围定义为本地目录和常见图片压缩包；明确章节排序、图片排序、损坏图片、重复导入和来源文件丢失的行为。

- [ ] **Step 2: 编写漫画阅读和缓存规格**

定义纵向滚动、横向翻页、预加载窗口、缓存分类、清理规则和阅读进度语义。在线漫画源明确排除在 Version 0.3 之外。

- [ ] **Step 3: 编写同步数据流**

定义首次全量同步与后续增量同步，使用服务端同步游标；定义客户端操作 ID、幂等键、服务端版本和协议版本。

- [ ] **Step 4: 编写冲突、删除和恢复规则**

逐实体规定冲突策略；删除使用可传播的 tombstone；客户端时间不作为唯一胜负依据；覆盖退避、断点恢复、游标失效和本地重建。

- [ ] **Step 5: 写入安全与隐私边界**

说明 Token 存储、HTTPS、日志脱敏、设备撤销、账号数据导出和删除需要满足的最低要求。

- [ ] **Step 6: 检查错误的简化同步表述**

Run:

```powershell
Select-String -Path docs/sync-protocol.md -Pattern '仅.*updated_at|只.*updated_at|客户端时间.*唯一'
```

Expected: 不出现依靠客户端 `updated_at` 作为唯一冲突依据的规则。

- [ ] **Step 7: 提交后续模块规格**

```bash
git add docs/manga-reader-spec.md docs/sync-protocol.md
git commit -m "docs: define manga and sync boundaries"
```

### Task 4: 建立质量与发布门槛

**Files:**

- Create: `docs/quality-strategy.md`
- Create: `docs/release-checklist.md`
- Create: `docs/decisions/README.md`

**Interfaces:**

- Consumes: 四阶段版本基线和各专题规格。
- Produces: 所有版本共用的验证方法、发布证据和架构决策记录格式。

- [ ] **Step 1: 编写测试层级和平台矩阵**

区分领域单元测试、数据层集成测试、Widget 测试、端到端手工路径和平台构建检查。MVP 0.1 只要求 Windows，MVP 0.2 增加 Android。

- [ ] **Step 2: 编写性能基准流程**

规定测试文件、机器信息、Flutter 版本、运行次数、中位数、峰值内存和结果记录格式。先测基线再冻结阈值。

- [ ] **Step 3: 定义质量门槛**

至少包含：

```text
flutter analyze
flutter test
flutter build windows
```

MVP 0.2 增加 Android 构建与主流程实机检查。文档不得声称尚未运行的命令已经通过。

- [ ] **Step 4: 编写发布检查表**

覆盖版本号、变更记录、许可证、安装说明、截图或演示、测试证据、已知问题、数据兼容和回滚说明。

- [ ] **Step 5: 编写 ADR 规则**

规定 ADR 文件名、背景、决策、备选方案、后果和状态；首批需要记录状态管理、路由、本地数据库和仓库结构选择。

- [ ] **Step 6: 检查文档不存在虚假结果**

Run:

```powershell
Select-String -Path docs/quality-strategy.md,docs/release-checklist.md -Pattern '已经通过|全部通过|构建成功'
```

Expected: 只描述门槛与记录方式，不声称当前模板工程已经满足未来版本标准。

- [ ] **Step 7: 提交质量体系**

```bash
git add docs/quality-strategy.md docs/release-checklist.md docs/decisions/README.md
git commit -m "docs: add quality and release standards"
```

### Task 5: 重构当前执行清单

**Files:**

- Modify: `docs/mvp-task-list.md`

**Interfaces:**

- Consumes: `plan.md`、`docs/data-model.md`、`docs/novel-reader-spec.md`、`docs/quality-strategy.md`。
- Produces: MVP 0.1 的唯一任务状态表和后续版本进入条件。

- [ ] **Step 1: 建立任务字段和状态规则**

每个任务使用 `M01-XXX` ID，并记录优先级、依赖、交付物、验收和状态。状态限定为 `planned`、`in_progress`、`blocked`、`done`。

- [ ] **Step 2: 拆解 MVP 0.1**

按工程骨架、本地数据库、媒体库、TXT 导入、阅读器、恢复、测试和发布证据组织任务。任务粒度必须能够独立验证。

- [ ] **Step 3: 增加阶段门槛**

0.2、0.3、0.4 只记录进入条件、退出条件和链接，不提前维护几十项远期任务。

- [ ] **Step 4: 删除范围冲突**

从 MVP 0.1 删除 EPUB、Android、漫画、账号、同步、下载、番剧和在线内容源的必做任务。

- [ ] **Step 5: 检查任务状态和范围**

Run:

```powershell
Select-String -Path docs/mvp-task-list.md -Pattern 'M01-[0-9]{3}|planned|in_progress|blocked|done'
Select-String -Path docs/mvp-task-list.md -Pattern '下载系统.*P0|番剧.*P0|账号.*MVP 0.1|同步.*MVP 0.1'
```

Expected: 第一条命令能找到任务 ID 和状态定义；第二条命令无结果。

- [ ] **Step 6: 提交执行清单**

```bash
git add docs/mvp-task-list.md
git commit -m "docs: make MVP tasks executable"
```

### Task 6: 收敛架构、目录和环境文档

**Files:**

- Modify: `docs/tech-architecture.md`
- Modify: `docs/project-structure.md`
- Modify: `docs/dev-setup.md`

**Interfaces:**

- Consumes: 总计划、专题规格、质量策略和 ADR 规则。
- Produces: 与当前实现阶段匹配、不会重复定义版本范围的工程指导。

- [ ] **Step 1: 重构技术架构**

保留 Flutter 本地优先架构，按 0.1、0.2、0.3、0.4 说明演进。架构文档只说明边界和数据流，字段、同步细节分别链接到专题文档。

- [ ] **Step 2: 明确当前仓库结构**

当前继续使用根目录 Flutter 工程；只有服务端实际启动或多客户端需求成立时，才评估迁移到 `client/flutter_app/`。删除“最终目录已经确定”的暗示。

- [ ] **Step 3: 更新 feature 目录顺序**

MVP 0.1 只要求 `app`、`core`、`shared`、`library`、`novel`；漫画和同步目录随对应版本创建，不提前制造空目录。

- [ ] **Step 4: 重写环境文档**

以项目配置和检查命令为准。历史机器实测信息移动为带日期的参考快照或删除；Go、PostgreSQL、Rust 明确不是 MVP 0.1 的环境前置条件。

- [ ] **Step 5: 检查环境与阶段一致性**

Run:

```powershell
Select-String -Path docs/dev-setup.md -Pattern 'MVP 0.1|Windows|Go|PostgreSQL|Rust'
Select-String -Path docs/project-structure.md -Pattern 'client/flutter_app'
```

Expected: 环境文档明确 MVP 0.1 只需要 Flutter/Windows 工具链；目录文档把顶层迁移写成有触发条件的未来决策。

- [ ] **Step 6: 提交工程指导文档**

```bash
git add docs/tech-architecture.md docs/project-structure.md docs/dev-setup.md
git commit -m "docs: align architecture with delivery stages"
```

### Task 7: 更新项目入口与文档治理

**Files:**

- Modify: `README.md`
- Modify: `docs/README.md`

**Interfaces:**

- Consumes: 所有已经完成的权威文档。
- Produces: 面向 GitHub 访问者的真实项目入口，以及面向维护者的完整文档索引。

- [ ] **Step 1: 重写根 README**

首屏说明项目价值、当前仍处于规划/工程初始化阶段、MVP 0.1 演示路径和真实支持状态。计划能力必须标记为计划，不写成已经支持。

- [ ] **Step 2: 增加路线和工程亮点**

简要说明阅读体验优先、离线优先、数据一致性、可测试性和渐进架构；避免用尚未引入的 Go/Rust 包装当前成熟度。

- [ ] **Step 3: 重建文档索引**

列出所有现有文档、阅读顺序、单一信息源和更新触发条件。删除已存在文档仍被列为“下一批待创建”的内容。

- [ ] **Step 4: 检查仓库内 Markdown 链接**

Run:

```powershell
$files = Get-ChildItem -Recurse -Filter *.md
$missing = foreach ($file in $files) {
  $text = Get-Content -LiteralPath $file.FullName -Raw
  foreach ($match in [regex]::Matches($text, '\[[^\]]+\]\((?!https?://|#)([^)#]+)(?:#[^)]+)?\)')) {
    $target = Join-Path $file.DirectoryName $match.Groups[1].Value
    if (-not (Test-Path -LiteralPath $target)) {
      "$($file.FullName): $($match.Groups[1].Value)"
    }
  }
}
$missing
```

Expected: 无输出。

- [ ] **Step 5: 提交入口文档**

```bash
git add README.md docs/README.md
git commit -m "docs: refresh project entry points"
```

### Task 8: 全局一致性与完成验证

**Files:**

- Verify: all `*.md`

**Interfaces:**

- Consumes: Tasks 1-7 的全部文档。
- Produces: 可审计的文档一致性检查结果。

- [ ] **Step 1: 检查占位符和过期表述**

Run:

```powershell
rg -n "TBD|TODO|第 [0-9]+ 个月|12 个月内|当前机器实测状态|下载系统.*P0|番剧.*P0" -g "*.md" -g "!docs/superpowers/**"
```

Expected: 无输出；若在解释性上下文出现，逐项人工确认并改成明确规则。

- [ ] **Step 2: 检查版本表述**

Run:

```powershell
rg -n "MVP 0\\.1|MVP 0\\.2|Version 0\\.3|Version 0\\.4" README.md plan.md docs
```

Expected: `plan.md` 包含四个版本定义；其他文件只引用相同范围，不出现下载、番剧、在线源或 Rust 被提前到 MVP 0.1/0.2。

- [ ] **Step 3: 检查 Markdown 差异**

Run:

```bash
git diff --check HEAD~7..HEAD
```

Expected: exit 0，无空白错误。

- [ ] **Step 4: 人工对照设计完成标准**

逐项对照：

```text
版本范围一致
平台顺序一致
早期排除项一致
任务顺序一致
导航完整
验收可验证
链接存在
无占位内容
```

每项必须能够指出对应文档和检查证据。

- [ ] **Step 5: 检查工作区**

Run:

```bash
git status --short
```

Expected: 无输出。

