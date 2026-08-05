# MVP 0.2 任务清单

状态：`pending` / `in_progress` / `done`

## Windows EPUB 主线

- [x] `M02-001` 依赖审计与可再分发 EPUB 2/3 样本（done：依赖锁定、许可证复核、自建 EPUB 2/3 样本及解析测试）
- [ ] `M02-002` EPUB 选择、验证、指纹与重复项处理（pending）
- [ ] `M02-003` 安全 ZIP 容器与资源预算（pending）
- [ ] `M02-004` container、OPF、NCX/nav 与 spine 解析（pending）
- [ ] `M02-005` XHTML 语义块、本地图片与安全降级（pending）
- [ ] `M02-006` 派生存储、原子导入与失败清理（pending）
- [ ] `M02-007` 详情目录、阅读器与语义进度（pending）
- [ ] `M02-008` Windows UI、错误信息与人工验收（pending）

## Windows EPUB 稳定后

- [ ] `M02-009` Android 主流程（pending）
- [ ] `M02-010` 书签（pending）
- [ ] `M02-011` 布局、导航与无障碍完善（pending）
- [ ] `M02-012` 性能验证与 `v0.2.0` 发布准备（pending）

## 阶段门槛

- DRM 不绕过，远程资源不加载，脚本不执行；
- Windows EPUB 闭环前不启动 Android、书签、漫画或在线内容源；
- 每个 done 项必须附带新的代码、测试或人工验证证据；
- TXT 导入、阅读、进度、归档、重定位和删除不得回归。
