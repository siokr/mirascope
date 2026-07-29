# mirascope 本地开发环境

## 1. 文档职责

本文提供可复现的开发环境要求和检查命令。具体依赖版本以仓库配置和锁文件为准，不保存无日期的个人机器状态。

## 2. MVP 0.1 必需环境

- Git；
- Flutter stable，且包含 `pubspec.yaml` 所要求的 Dart SDK；
- Windows 10/11；
- Visual Studio 2022 的 Desktop development with C++ 工作负载；
- 可运行 PowerShell 或等价终端。

Go、PostgreSQL、Rust、Android SDK、Xcode 和 Linux 工具链都不是 MVP 0.1 前置条件。

## 3. 首次检查

```bash
git --version
flutter --version
flutter doctor -v
flutter pub get
flutter devices
```

要求：

- Dart 版本满足 `pubspec.yaml`；
- Flutter Doctor 的 Windows toolchain 通过；
- `flutter devices` 能看到 Windows；
- 依赖获取完成。

如果只开发 MVP 0.1，可以暂时接受 Android、Xcode 或其他平台检查失败。

## 4. 日常命令

```bash
flutter pub get
flutter run -d windows
dart format --output=none --set-exit-if-changed lib test tool bin
flutter analyze
flutter test
flutter build windows
```

发布前的完整要求以 `docs/quality-strategy.md` 和 `docs/release-checklist.md` 为准。

仓库的 `.github/workflows/quality.yml` 会在推送和 Pull Request 时自动复核这些门槛。CI 结果是当次提交的自动化证据，不能代替 Windows 上的核心路径人工验收。

## 5. Android（MVP 0.2）

进入 MVP 0.2 后安装 Android Studio、Android SDK Platform、Command-line Tools 和 Build-Tools，并运行：

```bash
flutter doctor -v
flutter devices
flutter run -d <android-device-id>
flutter build apk
```

正式支持前必须在至少一台实际设备执行小说核心路径。模拟器不能完全替代存储权限和生命周期验证。

## 6. Go 与 PostgreSQL（Version 0.4）

只有进入 Version 0.4 才安装并固定最低版本。版本应写入服务端模块配置、CI 和开发容器，而不是仅写在本文。

验证命令：

```bash
go version
go env
psql --version
```

开发数据库凭据保存在未提交的本地环境文件或密钥管理中。仓库只提交示例变量名，不提交真实密码。

## 7. Rust（按基准触发）

Rust 不是固定版本阶段。ADR 接受 Rust 下沉后再安装 stable 工具链并验证：

```bash
rustup show
rustc -Vv
cargo -Vv
```

同时需要补充目标平台、FFI 代码生成、测试和发布步骤。

## 8. 环境快照规则

排查环境问题时可以记录快照，但必须包含：

```text
检测日期
操作系统
Flutter/Dart
目标平台工具链
执行命令
失败原文
```

快照放入 Issue、诊断记录或发布证据，不将某台机器的临时结果写成长期项目事实。

## 9. 常见问题

### Windows 设备不可见

确认 Flutter 已启用 Windows Desktop，Visual Studio 工作负载完整，然后重新运行 `flutter doctor -v`。

### Dart 版本不满足约束

升级或切换 Flutter SDK，不单独安装与 Flutter 不匹配的 Dart。

### 依赖解析后生成文件变化

先确认变化是否来自插件注册。如果只是运行工具产生且不属于当前任务，不应混入无关提交。

### 构建或测试失败

保留完整命令和首个根因错误。不要只删除缓存；先判断是环境、依赖还是代码问题。

### Windows 构建停在 CMake 且没有输出

当前维护者机器曾出现 MSVC 选择 `HostX86 → x64` 后挂起，而 GitHub `windows-latest` runner 可以成功构建同一提交。先检查 Visual Studio Installer 中的 Desktop development with C++、MSVC x64/x86 工具和 Windows SDK，再使用 `flutter doctor -v` 确认。

只终止能够确认属于本轮构建的进程。不要批量结束无关的 PowerShell、Dart 或编译进程，也不要把删除 Flutter 缓存作为首选修复。
