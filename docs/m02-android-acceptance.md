# MVP 0.2 Android 主流程验收

## 结论

`M02-009` Android 主流程验收通过。验证范围为 Android 调试构建；正式签名与 `v0.2.0` 发布包仍归入 `M02-012`。

## 环境

- Android 36 Google APIs x86_64 模拟器；
- Flutter 3.44.8；
- 应用 ID：`io.github.siokr.mirascope`；
- 候选提交：`5b91387`；
- GitHub Actions：Quality Gate #31，三个任务全部成功；
- Android 构建产物：`mirascope-android-0.1.0+1-debug`，75.6 MB。

## 人工验收结果

- TXT 文件选择、导入、详情、章节目录和阅读通过；
- EPUB 2、自建图片 EPUB 与真实 EPUB 的导入、详情、章节和阅读通过；
- 阅读进度在退出及重启应用后恢复通过；
- 阅读按键、Android 边缘返回手势、Home 与最近任务行为通过；
- 阅读设置保存通过；
- 重复导入打开已有条目通过；
- 归档、恢复、彻底删除及删除后重新导入通过；
- 文件选择器取消通过；
- 无效 EPUB 使用安全中文错误提示，不泄露路径或堆栈；
- 横竖屏切换通过；
- 竖屏媒体库卡片内容完整，未再出现 `BOTTOM OVERFLOWED`；
- 模拟器 Download 目录内的原始测试文件未被修改或删除。

## 自动验证

- Dart 格式检查通过；
- Flutter 静态分析通过；
- 284 项自动化测试通过；
- 本地 Android debug APK 构建与安装通过；
- GitHub Actions 的格式/分析/测试、Windows release、Android debug APK 三个任务全部通过。

## 非阻塞说明

- GitHub Actions 对 `actions/upload-artifact@v4` 显示 Node.js 20 弃用警告，但任务与产物均成功；后续可单独升级 action 版本消除警告。
- 模拟器中旧模板应用 ID `com.example.mirascope` 与稳定应用 ID 可同时存在，不影响正式应用数据；后续清理测试环境时可卸载旧应用。
