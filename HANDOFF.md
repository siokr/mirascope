# mirascope 项目交接说明

> 更新时间：2026-08-05
> 已发布版本：`v0.1.0`（提交 `5bec7ee`）
> 发布后记录：`0613f1a`

## 1. 当前状态

MVP 0.1 已正式发布，GitHub Release 提供经过 Windows Sandbox 验证的便携 ZIP。TXT 导入、编码识别、章节解析、详情目录、纵向阅读、设置、进度恢复、归档、来源重新定位、数据库迁移和整目录备份恢复均已取得自动化或人工证据。

正式标签构建运行 `30912830753`：格式、静态分析和 211 项测试通过，Windows release 构建通过。正式 ZIP SHA-256：

```text
474f71136d823f113d94835e74f1342183a911d379e040c12577eb3d38b7cae0
```

## 2. 下一阶段

下一阶段是 MVP 0.2，第一条产品增量为无 DRM EPUB 导入与基础阅读：

```text
同步已发布代码到 main
→ 建立 codex/m02-planning
→ 冻结 EPUB 支持边界和失败行为
→ 拆分可独立验证的任务
→ 先完成 Windows EPUB 闭环
→ Android 主流程、书签和阅读体验完善
```

不得在 EPUB、Android 和书签之外提前引入漫画、在线内容源、账号或同步。

## 3. 当前限制

### 本机 Windows release 工具链

本机 CMake/MSVC 原生 release 编译仍可能无输出挂起，但 debug 构建和真实窗口可运行。该问题只影响当前机器从源码生成 release，不再阻塞产品验收；GitHub Actions 标签构建和干净 Windows Sandbox 验证均已通过。

### 内容变化后的原位重解析

同指纹来源重新定位已完成；不同指纹会拒绝写入并保留旧派生内容。用户确认后的“生成新版本、映射章节和进度、原子替换”仍未实现。

### 大 TXT 内存

50 MiB TXT 的既有基线显示 RSS 增量中位数约 209.52 MiB。先观察真实使用，再依据可重复基准决定是否分块，不提前引入 FFI。

## 4. 数据与安全约束

- 不修改、移动或删除用户原文件；
- 来源丢失不删除媒体、章节、进度或设置；
- 指纹不同不静默替换；
- 重新解析失败必须保留旧的可读版本；
- 不用文件名或路径判断文件身份；
- 页面不直接访问文件系统或 Drift；
- 日志不记录完整路径、标题、正文、原始异常或堆栈；
- EPUB 必须防止 ZIP 路径穿越、资源炸弹、外部资源静默加载和脚本执行；
- DRM EPUB 明确拒绝，不尝试绕过。

## 5. Git 与验证

- MVP 0.2 开发基于最新 `main`；
- 合并优先使用 `--ff-only`；
- 不改写或移动已发布标签 `v0.1.0`；
- 不把旧测试数字复制为新阶段证据；
- 生成文件只有真实内容变化时才提交；
- 保留用户未跟踪的 `.vs/`；
- Drift 与 `drift_dev` 保持兼容版本。

## 6. 建议阅读顺序

1. `plan.md`
2. `docs/mvp-task-list.md`
3. `docs/novel-reader-spec.md`
4. `docs/data-model.md`
5. `docs/quality-strategy.md`
6. `lib/src/features/importing/`
7. `lib/src/features/novel/`
8. 对应的 `test/src/features/` 测试

## 7. 一句话状态

MVP 0.1 已作为 `v0.1.0` 发布；下一步从 EPUB 支持边界和任务拆分开始 MVP 0.2。
