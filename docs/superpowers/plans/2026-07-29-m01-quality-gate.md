# M01-016 自动化质量门槛实施计划

## 任务 1：建立 CI 工作流

- 新增 `.github/workflows/quality.yml`；
- 固定 Flutter 版本；
- 分离通用质量检查与 Windows release 构建；
- 限制权限并启用同分支并发取消。

## 任务 2：统一文档口径

- 将格式检查范围明确为 `lib test`；
- 在开发环境文档说明本地检查与远程 CI 的关系；
- 更新 `HANDOFF.md` 到 M01-016；
- 更新任务清单，但仅记录实际取得的证据。

## 任务 3：本地验证

依次运行：

```text
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
flutter build windows --release --no-pub
```

前三项必须取得当次结果。Windows 构建若仍受本机 MSVC 工具链阻塞，如实记录为本地阻塞；工作流需在推送后由 GitHub Windows runner 给出独立结果。

## 完成定义

- 工作流语法与配置经过检查；
- 本地格式、分析和测试通过；
- Windows 构建取得成功结果，或明确保留为等待远程 CI/本机工具链修复的阻塞项；
- 文档不声称尚未发生的远程运行已经通过。
