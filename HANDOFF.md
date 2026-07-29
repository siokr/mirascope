# mirascope 项目交接说明

> 更新时间：2026-07-29  
> 当前开发分支：`codex/m01-txt-encoding`  
> 当前分支 HEAD：`631271e`  
> 本地与远程 `main`：`0284884`

## 1. 现在做什么

项目正在推进 MVP 0.1 的本地 TXT 小说导入主链路：

```text
选择 TXT
→ 校验文件并计算指纹
→ 识别编码并规范化文本
→ 识别章节
→ 原子写入媒体库
→ 阅读与恢复进度
```

当前刚完成 `M01-008 TXT 编码与规范化` 的代码、自动化测试和验收记录，尚未合并到 `main`。

当前分支相对 `main` 新增的主要提交：

| 提交 | 内容 |
|---|---|
| `832b197` | 设计 TXT 编码与规范化 |
| `b0feb48` | 加入 GB18030 平台转换依赖 |
| `6964763` | 实现 TXT 编码识别与规范化 |
| `e4b46bb` | 接入 TXT 文件解码流程 |
| `631271e` | 记录 TXT 编码阶段验收情况 |

接手后第一件事不是重新实现编码模块，而是审查并快进合并当前分支。

## 2. 已经完成了什么

### 2.1 已完成并进入 `main`

- `M01-001`：工程基础决策；
- `M01-004`：日志与统一错误模型；
- `M01-005`：本地数据库与迁移；
- `M01-006`：媒体库；
- `M01-007` 的代码实现：TXT 文件选择、校验、流式 SHA-256 指纹和重复检测。

`M01-002`、`M01-003`、`M01-007` 在任务清单中仍为 `blocked`，原因不是相应代码未写，而是 Windows 实机启动验收被本机工具链问题阻塞。

### 2.2 当前分支完成的 M01-008

已实现：

- UTF-8 严格解码；
- UTF-8 BOM 识别和移除；
- UTF-16 LE/BE BOM 识别；
- UTF-16 奇数字节、孤立代理项拒绝；
- GB18030 双字节和四字节结构验证；
- `charset_converter` 平台 GB18030 转换适配；
- 固定识别顺序：BOM → 严格 UTF-8 → GB18030 → 用户选择；
- 未知编码返回 `encoding_unknown`，不静默乱码；
- 用户指定编码后严格重试；
- CRLF 和 CR 规范化为 LF；
- 保留连续空行、繁简、全角字符和标点；
- 空白或只有控制字符的正文拒绝；
- 最多 2000 个 Unicode 码点的安全预览，不截断代理对；
- 解码前后复查文件大小和修改时间；
- 文件变化返回 `source_changed`；
- 原文件只读，不修改；
- Riverpod 生产装配。

主要代码位置：

- `lib/src/features/importing/application/txt_decoder.dart`
- `lib/src/features/importing/application/decode_txt_source.dart`
- `lib/src/features/importing/application/importing_providers.dart`
- `lib/src/features/importing/data/charset_converter_gb18030_decoder.dart`
- `lib/src/features/importing/data/dart_io_txt_source_reader.dart`
- `lib/src/features/importing/domain/decoded_txt.dart`
- `lib/src/features/importing/domain/txt_encoding.dart`

设计与计划：

- `docs/superpowers/specs/2026-07-29-m01-txt-encoding-design.md`
- `docs/superpowers/plans/2026-07-29-m01-txt-encoding.md`

### 2.3 最近一次验证证据

在提交 `631271e` 前完成：

```text
dart format .                 100 个文件，0 变更
dart run build_runner build  成功
flutter analyze --no-pub     0 问题
flutter test --no-pub        138/138 通过
```

自动化测试使用自建字节样例，不包含商业小说正文或敏感路径。

## 3. 卡在哪里

### 3.1 主要阻塞：Windows MSVC 工具链

本机 Windows 原生构建在 CMake 识别 MSVC 时误选 `HostX86 → x64`，构建持续卡死；同一最小编译使用 `HostX64 → x64` 可以工作。

这个问题目前阻塞：

- Windows 应用真实启动；
- 原生文件选择器人工点击验收；
- `charset_converter` 的 Windows GB18030 实机转换验收；
- 完整 Windows 导入演示；
- `flutter build windows` 发布门槛。

不要把 138 项自动化测试通过写成“Windows 实机已验证”。在真实启动验收完成前，`M01-002`、`M01-003`、`M01-007`、`M01-008` 不能标记为 `done`。

### 3.2 数据模型缺口：编码尚无持久化字段

小说规格要求保存用户确认的编码，但当前 `ImportRecord` 没有编码字段。

已在 `M01-010` 中记录前置约束：

```text
为 ImportRecord 增加 textEncoding / text_encoding
并提供明确的 schema 迁移
```

M01-008 的 `DecodedTxt.encoding` 已携带真实编码。后续不得把编码塞进 `errorCode`、`sourceKind`、`contentRef` 或其他无关字段。

### 3.3 当前没有完整可点击导入链路

目前已有文件选择、校验、指纹、查重、解码与规范化能力，但尚未完成：

- 章节识别；
- 原子导入；
- 编码选择界面；
- 成功导入后的媒体库刷新。

因此媒体库暂时不应出现一个点击后无法完成导入的半成品按钮。

## 4. 下一步做什么

### 4.1 先合并当前分支

确认工作区干净且 `main` 是当前分支祖先：

```powershell
git status --short --branch
git merge-base main codex/m01-txt-encoding
git rev-parse main
```

然后执行本地快进合并：

```powershell
git switch main
git merge --ff-only codex/m01-txt-encoding
```

不要未经用户要求自动推送远程。

### 4.2 开始 M01-009：章节识别

推荐建立：

```text
codex/m01-chapter-detection
```

先写设计和表驱动样例，再实现解析器。必须覆盖 `docs/novel-reader-spec.md` 中至少这些独占行格式：

```text
第1章 标题
第一章 标题
第 12 章 标题
第十二回 标题
卷一 标题
第一卷 标题
Chapter 1 Title
```

实现要求：

- 章节标题必须独占一行；
- 使用合理长度上限；
- 正文偶然出现“第几章”不能切章；
- 不产生大量空章节；
- 保留原始字符偏移；
- 顺序稳定；
- 无可靠章节时生成单一“正文”章节；
- 输入使用 M01-008 的规范化文本；
- 不在 M01-009 写数据库。

### 4.3 然后进入 M01-010：原子导入

M01-010 才负责把以下步骤串成真实导入：

```text
文件候选
→ 解码结果
→ 章节结果
→ schema 编码字段迁移
→ 事务写入媒体、媒体库、章节和导入记录
→ 失败整体回滚
```

完成 M01-010 后再接入媒体库导入按钮和完整用户反馈。

### 4.4 Windows 工具链修复后补验收

工具链恢复后至少执行：

```powershell
flutter doctor -v
flutter devices
flutter run -d windows
flutter build windows
```

人工验证：

1. 选择一个 TXT；
2. 取消选择；
3. 选择空文件；
4. 重复选择相同内容；
5. 选择同名但内容不同的文件；
6. 验证 UTF-8、UTF-16 LE/BE、GB18030；
7. 验证未知编码进入选择和预览；
8. 确认日志没有完整路径或正文。

验收通过后再把相应 `blocked` 任务改为 `done`。

## 5. 哪些坑不要踩

### 状态和证据

- 不要因为代码写完就把任务标记为 `done`；
- 不要复制旧测试结果冒充当前验证；
- 不要把 Widget/单元测试描述为 Windows 实机验收；
- 不要忽略 `flutter build windows` 的失败或卡死；
- 不要为了让任务“看起来完成”删除阻塞说明。

### 文件与隐私

- 不修改、移动或删除用户原始 TXT；
- 不在日志记录完整路径、文件名、标题、正文、原始字节、异常或堆栈；
- 不把商业小说正文提交为测试 fixture；
- 不用文件名或路径判断重复内容；
- 不把完整大文件一次性用于指纹计算；指纹必须保持流式 SHA-256。

### 编码

- 不使用系统默认编码；
- 不使用 `allowMalformed: true`；
- 不用替换字符掩盖解码错误；
- 不引入概率型编码猜测并静默采用结果；
- ASCII 必须稳定归为 UTF-8；
- UTF-16 必须严格验证字节数和代理对；
- GB18030 自动识别必须先通过完整字节结构验证；
- 换行规范化不能顺便转换繁简、全角或标点；
- 不重复计算指纹来代替 M01-007 的候选身份。

### 架构

- `domain` 和 `application` 不得直接依赖 Drift、`file_selector` 或 `charset_converter`；
- 平台插件只能留在 data/platform 适配层；
- 页面不能直接读文件、计算哈希、解码或写数据库；
- M01-009 只解析章节，不写数据库；
- M01-010 必须通过 Repository 事务提交，不能逐表随意写入；
- 不借用无关数据库字段保存编码。

### Git 与生成文件

- 当前分支尚未合并，不要从旧 `main` 重写同一功能；
- 合并应使用 `--ff-only`，除非确实出现分叉并完成审查；
- 不自动推送，除非用户明确要求；
- 运行 `flutter pub get` 或 `build_runner` 后先检查生成文件差异；
- Windows 换行有时会让 Git 暂时显示文件已修改；先用 `git diff` 确认，不要提交无内容差异；
- 不混入无关依赖升级，特别是 Drift 运行库和 `drift_dev` 必须保持兼容版本。

## 6. 接手时建议阅读顺序

1. `HANDOFF.md`
2. `docs/mvp-task-list.md`
3. `docs/novel-reader-spec.md`
4. `docs/data-model.md`
5. `docs/superpowers/specs/2026-07-29-m01-txt-encoding-design.md`
6. `lib/src/features/importing/application/txt_decoder.dart`
7. `lib/src/features/importing/application/decode_txt_source.dart`
8. 对应的 `test/src/features/importing/` 测试

## 7. 一句话项目状态

媒体库、数据库、错误模型、TXT 文件身份和文本解码的自动化基础已经建立；当前真正缺的是章节解析和原子导入，同时 Windows 原生工具链仍阻止实机验收。
