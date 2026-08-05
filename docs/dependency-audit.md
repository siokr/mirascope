# 第三方依赖审计

## EPUB 基础依赖（2026-08-05）

| 包 | 锁定版本 | 用途 | 许可证 | 平台结论 |
|---|---:|---|---|---|
| `archive` | 4.0.9 | ZIP entry 枚举与受控解压 | MIT | Dart 实现，声明支持 Windows、Android 等主流平台 |
| `xml` | 7.0.1 | container、OPF、NCX XML 解析 | MIT | Dart 实现，声明支持 Windows、Android 等主流平台 |
| `html` | 0.15.6 | XHTML 容错解析与 DOM 清理 | 类 MIT 三条款宽松许可证 | Dart 实现，声明支持 Windows、Android 等主流平台 |

许可证以下载到 Pub 缓存内的各包 `LICENSE` 原文复核。三者允许在 MIT 项目中使用和再分发；发布产物需要保留相应版权与许可文本。正式发布前应生成第三方声明清单，不把项目的 MIT 许可证误写成依赖代码的唯一许可证。

选择底层组合而非高层 EPUB 包，是为了让路径规范化、解压预算、加密检测、活动内容清理和失败原子性保持在项目自己的可测试边界内。

## 测试语料

`test/support/epub_test_fixture.dart` 现场生成确定性的 EPUB 2 和 EPUB 3 最小样本。元数据与正文由本项目创作，可随项目 MIT 许可证分发，不包含第三方小说内容。样本分别覆盖 NCX 与 EPUB navigation document，并同时验证 ZIP、XML 和 XHTML 解析依赖。
