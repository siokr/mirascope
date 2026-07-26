# mirascope 本地开发环境搭建

这份文档用于统一 `mirascope` 的本地开发环境，避免后面开始拆工程时每个工具链状态都不一致。

---

## 1. 当前仓库现状

当前仓库还是 Flutter 初始工程，已补充产品与技术文档，但业务代码尚未正式开始。

已存在：

- Flutter 多端工程骨架
- `plan.md`
- `docs/mvp-task-list.md`
- `docs/tech-architecture.md`
- `docs/README.md`

接下来真正开发前，建议先把本地环境统一好。

---

## 2. 推荐工具链

`mirascope` 当前建议使用以下主技术栈：

- Flutter
- Dart
- Go
- Rust
- PostgreSQL

可选补充：

- Android Studio
- Visual Studio 2022
- Chrome
- Git

---

## 3. 当前机器实测状态

以下信息基于当前仓库环境实测：

### Flutter / Dart

- Flutter: `3.44.8`
- Dart: `3.12.2`
- 当前 `pubspec.yaml` 约束：`sdk: ^3.12.2`

### Rust

- Cargo: `1.97.1`
- `cargo` 可用
- `rustc` 路径存在，但当前命令输出异常，建议重新检查 Rust 工具链完整性

### Go

- 当前未安装或未加入 PATH

### PostgreSQL

- 当前 `psql` 不可用，说明 PostgreSQL 客户端未安装或未加入 PATH

### Flutter Doctor

当前可用：

- Windows 桌面开发
- Web 开发
- Visual Studio 2022
- Chrome

当前问题：

- Android SDK 路径存在，但 `ANDROID_HOME = F:\dev\AndroidSDK` 下未检测到有效 SDK

---

## 4. 最低开发环境要求

建议至少满足：

- Windows 10/11
- Flutter stable
- Dart 与 Flutter 自带版本保持一致
- Visual Studio 2022（Windows 桌面）
- Chrome（Web 调试）
- Go 1.24+
- Rust stable
- PostgreSQL 16+

如果暂时只做 Flutter 客户端 Phase 0 / Phase 1，可以先不安装 Go 和 PostgreSQL；但在进入账号与同步阶段前必须补齐。

---

## 5. Flutter 环境搭建

### 5.1 检查 Flutter

运行：

```bash
flutter --version
flutter doctor -v
```

目标：

- Flutter stable 可用
- Windows 或目标平台工具链正常
- Chrome 可用

### 5.2 当前已确认版本

```text
Flutter 3.44.8
Dart 3.12.2
```

### 5.3 安装建议

如果本地没有 Flutter：

1. 安装 Flutter stable SDK
2. 把 Flutter `bin` 目录加入 PATH
3. 运行 `flutter doctor -v`
4. 根据提示补装缺失依赖

### 5.4 推荐扩展

IDE 可选：

- VS Code
- Android Studio

推荐安装：

- Flutter 插件
- Dart 插件

---

## 6. Android 环境修复

当前问题：Flutter 已检测到 `ANDROID_HOME`，但目标目录下没有有效 Android SDK。

### 6.1 建议修复步骤

1. 安装 Android Studio
2. 打开 SDK Manager
3. 安装以下内容：
   - Android SDK Platform
   - Android SDK Command-line Tools
   - Android SDK Build-Tools
   - Android Emulator（如需要）
4. 确认 SDK 实际安装路径
5. 修正 `ANDROID_HOME` 或 `ANDROID_SDK_ROOT`
6. 运行：

```bash
flutter doctor -v
```

### 6.2 判断修复成功

满足以下任一条件即可：

- `flutter doctor -v` 中 Android toolchain 变为通过
- `flutter devices` 能识别 Android 模拟器或真机

---

## 7. Go 环境搭建

Go 用于后续服务端开发，目前本机尚未可用。

### 7.1 安装目标

建议版本：

- Go `1.24+`

### 7.2 安装后验证

运行：

```bash
go version
```

期望：

- 能输出 Go 版本
- `go` 命令在终端可直接使用

### 7.3 建议后续补充验证

```bash
go env
```

重点确认：

- `GOROOT`
- `GOPATH`
- `GOOS`
- `GOARCH`

---

## 8. Rust 环境检查

Rust 用于后续高性能解析、下载和文件处理模块。

### 8.1 当前状态

- `cargo` 可用
- 当前 `cargo -Vv` 输出正常
- `rustc` 路径存在，但版本命令输出异常

### 8.2 建议检查步骤

运行：

```bash
cargo -Vv
rustup show
rustc -Vv
```

如果 `rustc` 依旧没有正常输出，建议：

1. 执行 `rustup update`
2. 执行 `rustup default stable`
3. 检查 PATH 中是否存在冲突的 `rustc`
4. 必要时重新安装 Rust stable toolchain

### 8.3 判断修复成功

满足以下条件：

- `cargo` 正常
- `rustc -Vv` 正常输出
- 后续可以创建并构建最小 Rust 工程

---

## 9. PostgreSQL 环境搭建

PostgreSQL 用于后续账号与同步服务端。

### 9.1 当前状态

- `psql` 当前不可用

### 9.2 建议版本

- PostgreSQL `16+`

### 9.3 安装后验证

运行：

```bash
psql --version
```

### 9.4 本地开发建议

建议至少准备：

- 一个本地 PostgreSQL 实例
- 一个开发数据库，例如 `mirascope_dev`
- 一个测试数据库，例如 `mirascope_test`

### 9.5 推荐初始化项

后续可统一约定：

- 数据库名：`mirascope_dev`
- 用户名：`mirascope`
- 密码：本地 `.env` 保存，不写入仓库
- 端口：默认 `5432`

---

## 10. Visual Studio 与 Windows 桌面

当前 Flutter Doctor 已确认：

- Visual Studio Community 2022 可用
- Windows 桌面工具链可用

这意味着当前最适合先做：

- Windows 桌面端 Flutter 开发
- Web 端快速调试

如果你准备先推进 Phase 0 / Phase 1，这个环境已经够用。

---

## 11. 推荐命令清单

### Flutter

```bash
flutter pub get
flutter run -d windows
flutter run -d chrome
flutter test
flutter analyze
```

### Go

```bash
go version
go env
```

### Rust

```bash
cargo -Vv
rustup show
rustc -Vv
```

### PostgreSQL

```bash
psql --version
```

---

## 12. 开发前检查清单

在真正开始 Phase 0 代码改造前，建议逐项确认：

- [ ] `flutter doctor -v` 只有可接受问题
- [ ] Windows 端 `flutter run -d windows` 可运行
- [ ] Chrome 端 `flutter run -d chrome` 可运行
- [ ] Android SDK 已修复或明确暂缓 Android 调试
- [ ] Go 已安装并可执行 `go version`
- [ ] Rust 工具链状态正常
- [ ] PostgreSQL 已安装并可执行 `psql --version`

---

## 13. 当前最建议的下一步

按照当前环境状态，建议顺序是：

1. 修复 Android SDK 配置
2. 安装 Go
3. 安装 PostgreSQL
4. 检查 Rust 工具链完整性
5. 开始 Flutter Phase 0 工程重构

如果你决定先只做客户端，也可以把步骤压缩成：

1. 修复 Android SDK
2. 确认 Windows / Chrome 正常运行
3. 直接开始 Flutter 工程骨架重构

---

## 14. 一句话结论

当前这台机器已经足够开始 `mirascope` 的 Flutter 客户端开发，但要进入后端同步阶段，还需要补齐 Go、PostgreSQL，并顺手修复 Android SDK 和 Rust 工具链状态。
