# mirascope 文档目录

这份文档用于说明当前 `mirascope` 仓库里的文档分工，避免计划、架构、执行清单混在一起，后面越写越乱。

---

## 1. 当前文档结构

### `plan.md`

定位：项目总计划表

适合回答：

- 这个项目到底想做什么
- MVP 和长期目标分别是什么
- 版本路线如何安排
- 优先级怎么排序

### `docs/mvp-task-list.md`

定位：MVP 执行清单

适合回答：

- 当前阶段具体做什么
- 哪些任务属于 P0 / P1 / P2
- 一阶段做到什么程度算完成

### `docs/tech-architecture.md`

定位：技术架构设计文档

适合回答：

- Flutter、Go、Rust 分别负责什么
- 客户端怎么分层
- 本地数据和同步系统怎么设计
- 后续为什么这样扩展不会太痛苦

### `docs/dev-setup.md`

定位：本地开发环境搭建文档

适合回答：

- 当前机器的开发环境还缺什么
- Flutter / Go / Rust / PostgreSQL 怎么准备
- 开始 Phase 0 前应该先检查哪些工具链

### `docs/project-structure.md`

定位：项目目录结构说明文档

适合回答：

- 仓库应该怎么分层
- Flutter 客户端目录应该怎么拆
- 每个目录该放什么、不该放什么

---

## 2. 建议阅读顺序

如果你是项目负责人或自己一个人推进，建议这样读：

1. 先读 `plan.md`
2. 再读 `docs/mvp-task-list.md`
3. 再读 `docs/tech-architecture.md`
4. 开工前读 `docs/dev-setup.md`
5. 开始搭工程时读 `docs/project-structure.md`

原因：

- 先看方向
- 再看执行
- 最后看实现

---

## 3. 文档分工原则

后面继续补文档时，建议遵守下面的边界：

- `plan.md` 只写产品目标、范围、里程碑、优先级
- `docs/mvp-task-list.md` 只写任务拆解、阶段目标、验收项
- `docs/tech-architecture.md` 只写技术设计、模块边界、数据流
- `docs/project-structure.md` 只写目录结构、代码组织和落地规则

不要把下面这些内容重新混回总计划：

- 具体接口字段
- 代码目录实现细节
- 每日开发流水账
- 临时想到的功能点

---

## 4. 建议下一批文档

等真正开始写业务代码后，建议按顺序继续补：

1. `docs/dev-setup.md`
   - 本地开发环境搭建
   - Flutter / Go / Rust / PostgreSQL 依赖说明
2. `docs/project-structure.md`
   - 客户端目录结构、模块边界和落地规则
3. `docs/api-design.md`
   - 登录、同步、设置等核心 API 设计
4. `docs/data-model.md`
   - 本地数据库与服务端数据模型说明
5. `docs/release-checklist.md`
   - MVP / Beta 发版检查项

---

## 5. 当前最推荐的动作

如果接下来开始动代码，建议优先做：

- 把 Flutter 默认模板替换掉
- 建立 `lib/src/app`、`lib/src/core`、`lib/src/features` 结构
- 配好状态管理、路由、本地数据库
- 先把书架和小说阅读链路做出来

---

## 6. 一句话总结

当前这套文档体系的目标，是先把 `mirascope` 从“想法很多”整理成“方向清楚、执行有序、架构可落地”的项目。
