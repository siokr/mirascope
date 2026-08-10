# Version 0.3 依赖与平台能力审计

> 审计日期：2026-08-10

## 结论

M03 首批不需要新增运行时依赖。现有 `file_selector 1.1.0`、`archive 4.0.9` 和 Flutter 自带图片解码能力足以开始目录/ZIP/CBZ 扫描与 JPEG/PNG/WebP 验证。具体图片格式和 Android 目录跨重启访问仍须由 `M03-003`、`M03-005` 的真实平台测试确认，不能仅凭 API 存在判定完成。

## 已锁定能力

| 能力 | 当前依赖 | Windows | Android | 许可证 | 决定 |
|---|---|---:|---:|---|---|
| 单文件 ZIP/CBZ 选择 | `file_selector 1.1.0` | 支持 | 支持 | BSD-3-Clause；Android 实现含 Apache-2.0/BSD-3-Clause | 复用 |
| 目录选择 | `file_selector 1.1.0` | 支持 | 官方表列为支持 | 同上 | 复用 API；跨重启权限单独实机验证 |
| ZIP 读取 | `archive 4.0.9` | 支持 | 支持 | MIT，附带第三方许可正文 | 复用；继续使用项目自己的路径与资源预算门槛 |
| 图片显示/解码 | Flutter engine | 待真实样例确认 | 待真实样例确认 | 随 Flutter 分发许可 | 首期验证 JPEG、PNG、WebP，不新增图片包 |
| 缩略图 | Flutter engine | 可行性待实现测试 | 可行性待实现测试 | 随 Flutter 分发许可 | 先测再决定是否需要新依赖 |

当前锁文件中的平台实现为 `file_selector_android 0.5.2+9` 和 `file_selector_windows 0.9.3+5`。版本升级必须重新运行本审计关注的目录、文件和取消选择测试。

## 安全判断

- `archive` 提供 ZIP 解码能力，不替代应用自己的安全策略；条目路径仍须规范化并拒绝绝对路径、盘符和 `..` 越界；
- 不直接调用“一键解压整个目录”作为导入实现；先枚举元数据、验证预算，再按受控清单读取；
- CBZ 按 ZIP 容器处理，但扩展名不能代替签名验证；
- 加密条目整体拒绝，不尝试破解或降级为部分导入；
- Android 目录选择返回可访问路径不等于永久权限已得到保证，必须验证重启、权限撤销和来源丢失；
- 首批不加入 RAR/CBR、7z、PDF、原生图片库或缓存框架，避免许可证、原生构建和内存模型同时扩大。

## 可再分发样例

漫画样例不使用商业作品或网络图片。`test/support/manga_test_fixture.dart` 在测试运行时生成纯色 1×1 PNG、自然排序章节、损坏页、路径穿越和条目冲突 ZIP；固定时间戳保证结构可重复。后续 JPEG/WebP 解码样例也必须由项目自行生成并在样例说明中记录生成方式。

## 官方依据

- `file_selector` 平台能力与目录 API：<https://pub.dev/packages/file_selector>
- `file_selector_android` 官方实现：<https://pub.dev/packages/file_selector_android>
- `archive` 包与 API：<https://pub.dev/packages/archive>
- Flutter 支持的图片格式说明：<https://docs.flutter.dev/ui/assets/assets-and-images#loading-images>

## 后续门槛

1. `M03-003` 在 Windows 和 Android 实测目录选择、取消、重启访问和权限撤销；
2. `M03-004` 复用 EPUB 安全容器经验，但为漫画冻结独立的条目数、单页和总展开预算；
3. `M03-005` 用自行生成的 JPEG、PNG、WebP 和损坏文件确认真实解码行为；
4. 只有现有能力无法满足可重复验收时，才提出新依赖并补许可证、维护状态和跨平台成本。
