# M01-006 媒体库实施计划

> 对应设计：`docs/superpowers/specs/2026-07-29-m01-media-library-design.md`

## 实施原则

- 每项行为先写失败测试，再实现最小代码，再运行聚焦测试。
- 数据库排序和状态约束由 Repository 保证，界面不复制业务规则。
- 页面只消费领域模型和 Provider，不导入 Drift 类型。
- 归档只更新 `LibraryEntry.archivedAt`，不得调用永久删除接口。
- 所有用户提示使用稳定文案，普通日志不得包含标题、路径、原始异常或堆栈。
- 每个任务独立提交，提交信息使用简洁中文。

## Task 1：补齐媒体库 Repository 行为

**修改：**

- `lib/src/features/library/domain/media_library_repository.dart`
- `lib/src/features/library/data/drift_media_library_repository.dart`
- `test/src/features/library/data/drift_media_library_repository_test.dart`

**新增接口：**

```dart
Stream<List<LibraryItem>> watchArchivedLibrary();
Future<void> markOpened(String mediaItemId, DateTime openedAt);
```

**步骤：**

1. 先补失败测试：
   - 归档流只返回归档条目；
   - 归档流按 `archivedAt desc`、`addedAt desc`、`id asc` 稳定排序；
   - 活动流在已有排序后追加 `id asc`；
   - `markOpened` 更新未归档条目并改变活动排序；
   - `markOpened` 拒绝归档条目和不存在条目；
   - 重复归档、重复恢复和不存在目标均失败；
   - 时间参数被规范为 UTC。
2. 运行聚焦测试，保存 RED 证据。
3. 用带状态条件的 `UPDATE` 实现动作，并检查 affected row count。
4. 抽取共享的 join 映射，避免活动和归档查询复制领域转换。
5. 运行：

```powershell
flutter test --no-pub test/src/features/library/data/drift_media_library_repository_test.dart
flutter analyze --no-pub
```

6. 提交：

```text
完善媒体库数据操作
```

## Task 2：增加媒体库状态与动作层

**新增：**

- `lib/src/features/library/application/library_providers.dart`
- `lib/src/features/library/application/library_actions_controller.dart`
- `test/src/features/library/application/library_actions_controller_test.dart`
- `test/src/features/library/application/library_providers_test.dart`

**修改：**

- `lib/src/core/database/database_providers.dart`

**接口与状态：**

- `activeLibraryProvider`
- `archivedLibraryProvider`
- `libraryClockProvider`
- `libraryActionsProvider`
- 每个媒体 ID 独立的忙碌状态；
- `LibraryActionFailure` 稳定动作类型，不携带原始异常。

**步骤：**

1. 用内存 Fake Repository 写失败测试：
   - Provider 转发两个 Repository 流；
   - 打开动作使用注入的 UTC 时钟；
   - 写入成功后才调用导航回调；
   - 写入失败时不导航；
   - 同一媒体 ID 的重复动作被阻止；
   - 不同媒体 ID 的动作互不阻塞；
   - 归档、恢复失败映射为稳定错误类型。
2. 运行聚焦测试，保存 RED。
3. 实现最小 Provider 与 controller。
4. controller 只保留动作进行状态，不缓存媒体列表。
5. 运行：

```powershell
flutter test --no-pub test/src/features/library/application
flutter analyze --no-pub
```

6. 提交：

```text
接入媒体库状态管理
```

## Task 3：实现媒体卡片和四类列表状态

**新增：**

- `lib/src/features/library/presentation/widgets/library_grid.dart`
- `lib/src/features/library/presentation/widgets/library_card.dart`
- `lib/src/features/library/presentation/widgets/library_loading_grid.dart`
- `lib/src/features/library/presentation/widgets/library_error_state.dart`
- `test/src/features/library/presentation/library_grid_test.dart`
- `test/src/features/library/presentation/library_card_test.dart`

**步骤：**

1. 先写 Widget 失败测试：
   - 2:3 封面占位、标题、作者或副标题、最近打开文案；
   - 占位封面颜色对同一媒体 ID 稳定；
   - 长标题和元数据不溢出；
   - 卡片主体、菜单、Tooltip 和语义标签可发现；
   - loading 骨架与网格列宽一致；
   - error 状态提供重试；
   - 600、900、1440 像素宽度下列数和布局正确。
2. 运行聚焦测试，保存 RED。
3. 使用 Material 3、`LayoutBuilder` 和固定最大内容宽度实现组件。
4. 不读取本地 `coverRef` 文件；真实封面加载留给后续封面管线。
5. 动效仅使用 Material 内建反馈，不引入动画依赖。
6. 运行：

```powershell
flutter test --no-pub test/src/features/library/presentation/library_grid_test.dart test/src/features/library/presentation/library_card_test.dart
flutter analyze --no-pub
```

7. 提交：

```text
实现媒体库封面网格
```

## Task 4：接入活动媒体库页面

**修改：**

- `lib/src/features/library/presentation/library_page.dart`
- `lib/src/app/routing/app_router.dart`
- `test/widget_test.dart`
- `test/src/app/routing/app_router_test.dart`

**新增：**

- `test/src/features/library/presentation/library_page_test.dart`

**步骤：**

1. 先写失败测试：
   - loading、empty、error、data 四种状态；
   - 错误重试会刷新活动流；
   - 点击小说先保存打开时间，再导航详情；
   - 保存失败时不导航并显示安全 SnackBar；
   - 归档确认框明确说明不删除原文件；
   - 取消确认不调用 Repository；
   - 归档成功后显示撤销；
   - 撤销调用恢复；
   - 同条目动作进行中时菜单禁用。
2. 将 `LibraryPage` 改为 Consumer 页面，读取活动流和动作 controller。
3. 为测试允许注入导航回调，生产路由使用 `context.go` 或 `context.push`。
4. 保留设置入口，增加已归档入口。
5. M01-007 前空状态不显示无效导入按钮。
6. 运行：

```powershell
flutter test --no-pub test/src/features/library/presentation/library_page_test.dart test/src/app/routing/app_router_test.dart test/widget_test.dart
flutter analyze --no-pub
```

7. 提交：

```text
接入正式媒体库页面
```

## Task 5：实现独立归档页面与路由

**新增：**

- `lib/src/features/library/presentation/archived_library_page.dart`
- `test/src/features/library/presentation/archived_library_page_test.dart`

**修改：**

- `lib/src/app/routing/app_routes.dart`
- `lib/src/app/routing/app_router.dart`
- `test/src/app/routing/app_router_test.dart`

**步骤：**

1. 先写失败测试：
   - `/library/archive` 能打开归档页并返回；
   - loading、empty、error、data 四种状态；
   - 恢复成功后条目从归档列表消失；
   - 恢复失败显示稳定 SnackBar；
   - 窄窗口不溢出；
   - 页面不提供永久删除操作。
2. 实现归档页面并复用 Task 3 网格组件。
3. 恢复动作直接使用 controller，不复制 Repository 调用。
4. 运行：

```powershell
flutter test --no-pub test/src/features/library/presentation/archived_library_page_test.dart test/src/app/routing/app_router_test.dart
flutter analyze --no-pub
```

5. 提交：

```text
新增已归档媒体页面
```

## Task 6：验证持久化流程与安全边界

**新增：**

- `test/src/features/library/library_persistence_flow_test.dart`

**可能修改：**

- 前述媒体库文件，仅用于修复该集成测试暴露的问题。

**步骤：**

1. 使用同一个临时内存数据库验证：
   - 插入多个媒体和条目；
   - 活动流按预期排序；
   - 打开后 `lastOpenedAt` 写入；
   - 重建 Repository 和 ProviderContainer 后排序保持；
   - 归档后活动流消失、归档流出现；
   - 恢复后重新进入活动流；
   - `MediaItem`、`ImportRecord.sourcePath` 和其他应用数据均未删除。
2. 审计：

```powershell
rg -n "deleteApplicationData|delete\\(" lib/src/features/library/presentation lib/src/features/library/application
rg -n "package:drift" lib/src/features/library/domain lib/src/features/library/presentation
rg -n "appLogger.*(error|stackTrace|sourcePath|title)" lib/src/features/library
```

3. 运行：

```powershell
flutter test --no-pub test/src/features/library
flutter analyze --no-pub
git diff --check
```

4. 提交：

```text
验证媒体库持久化流程
```

## Task 7：最终验收与任务状态

**修改：**

- `docs/mvp-task-list.md`

**步骤：**

1. 运行生成与格式检查：

```powershell
dart run build_runner build
dart format .
```

2. 运行全量验证：

```powershell
flutter analyze --no-pub
flutter test --no-pub
dart run drift_dev schema dump lib/src/core/database/app_database.dart drift_schemas
git diff --exit-code -- drift_schemas/drift_schema_v1.json
dart run drift_dev schema generate drift_schemas test/generated_migrations
git diff --exit-code -- test/generated_migrations
git diff --check
```

3. 在 600、900、1440 像素宽度下检查：
   - 活动空状态；
   - 活动网格；
   - 归档网格；
   - 长标题；
   - loading 和 error；
   - 浅色与深色主题。
4. 完成独立代码复审，修复所有 Critical 和 Important 问题。
5. 只有设计文档完成标准全部满足时，将 M01-006 改为 `done`，写入提交和验证证据。
6. 不改变 M01-002、M01-003 的 Windows 工具链阻塞，也不提前完成 M01-007。
7. 提交：

```text
记录媒体库阶段完成情况
```
