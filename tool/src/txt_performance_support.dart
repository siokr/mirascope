import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

final class TxtBenchmarkSample {
  const TxtBenchmarkSample(this.name, this.targetBytes);

  final String name;
  final int targetBytes;
}

const txtBenchmarkSamples = <TxtBenchmarkSample>[
  TxtBenchmarkSample('small', 100 * 1024),
  TxtBenchmarkSample('regular', 5 * 1024 * 1024),
  TxtBenchmarkSample('large', 50 * 1024 * 1024),
];

Future<void> generateTxtBenchmarkSample(
  File target,
  TxtBenchmarkSample sample,
) async {
  await target.parent.create(recursive: true);
  final sink = target.openWrite();
  var written = 0;
  var chapter = 1;
  const chapterBytes = 64 * 1024;

  try {
    while (written < sample.targetBytes) {
      final heading = utf8.encode(
        'Chapter ${chapter.toString().padLeft(6, '0')} ${sample.name}\n',
      );
      final remaining = sample.targetBytes - written;
      final blockLength = remaining < chapterBytes ? remaining : chapterBytes;
      final block = Uint8List(blockLength);
      final headingLength = heading.length < blockLength
          ? heading.length
          : blockLength;
      block.setRange(0, headingLength, heading);
      if (blockLength > headingLength) {
        block.fillRange(headingLength, blockLength, 0x61);
        block[blockLength - 1] = 0x0a;
      }
      sink.add(block);
      written += blockLength;
      chapter++;
    }
  } finally {
    await sink.close();
  }
}

int medianInt(Iterable<int> values) {
  final sorted = values.toList()..sort();
  if (sorted.isEmpty) {
    throw ArgumentError.value(values, 'values', 'Must not be empty');
  }
  return sorted[sorted.length ~/ 2];
}

String formatMilliseconds(int microseconds) =>
    (microseconds / 1000).toStringAsFixed(3);

String formatMebibytes(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(2);

String renderTxtBenchmarkMarkdown(Map<String, Object?> report) {
  final environment = report['environment']! as Map<String, Object?>;
  final samples = report['samples']! as List<Object?>;
  final buffer = StringBuffer()
    ..writeln('# mirascope TXT 性能基线')
    ..writeln()
    ..writeln('> 本报告是首次测量基线，不代表已经冻结性能阈值。')
    ..writeln()
    ..writeln('## 环境')
    ..writeln()
    ..writeln('| 项目 | 值 |')
    ..writeln('|---|---|')
    ..writeln('| 日期 | ${environment['date']} |')
    ..writeln('| Git commit | `${environment['git_commit']}` |')
    ..writeln('| 操作系统 | ${environment['operating_system']} |')
    ..writeln('| CPU | ${environment['cpu']} |')
    ..writeln('| 逻辑处理器 | ${environment['processors']} |')
    ..writeln('| 物理内存 | ${environment['total_memory']} |')
    ..writeln('| Flutter | ${environment['flutter_version']} |')
    ..writeln('| Dart | ${environment['dart_version']} |')
    ..writeln('| 构建模式 | ${environment['build_mode']} |')
    ..writeln('| 预热 / 正式运行 | 1 / 3 |')
    ..writeln()
    ..writeln('## 中位数')
    ..writeln()
    ..writeln('| 样本 | 大小 | 章节 | 导入 | 首次打开 | 章节切换 | RSS 峰值 | RSS 增量 |')
    ..writeln('|---|---:|---:|---:|---:|---:|---:|---:|');

  for (final value in samples) {
    final sample = value! as Map<String, Object?>;
    final median = sample['median']! as Map<String, Object?>;
    buffer.writeln(
      '| ${sample['name']} '
      '| ${formatMebibytes(sample['bytes']! as int)} MiB '
      '| ${median['chapter_count']} '
      '| ${formatMilliseconds(median['import_us']! as int)} ms '
      '| ${formatMilliseconds(median['open_us']! as int)} ms '
      '| ${formatMilliseconds(median['switch_us']! as int)} ms '
      '| ${formatMebibytes(median['rss_peak_bytes']! as int)} MiB '
      '| ${formatMebibytes(median['rss_delta_bytes']! as int)} MiB |',
    );
  }

  buffer
    ..writeln()
    ..writeln('## 原始结果')
    ..writeln();

  for (final value in samples) {
    final sample = value! as Map<String, Object?>;
    final runs = sample['runs']! as List<Object?>;
    buffer
      ..writeln('### ${sample['name']}')
      ..writeln()
      ..writeln('SHA-256：`${sample['sha256']}`')
      ..writeln()
      ..writeln(
        '| 次数 | 导入 ms | 首次打开 ms | 章节切换 ms | RSS 起始 MiB | RSS 峰值 MiB | RSS 增量 MiB |',
      )
      ..writeln('|---:|---:|---:|---:|---:|---:|---:|');
    for (var index = 0; index < runs.length; index++) {
      final run = runs[index]! as Map<String, Object?>;
      buffer.writeln(
        '| ${index + 1} '
        '| ${formatMilliseconds(run['import_us']! as int)} '
        '| ${formatMilliseconds(run['open_us']! as int)} '
        '| ${formatMilliseconds(run['switch_us']! as int)} '
        '| ${formatMebibytes(run['rss_start_bytes']! as int)} '
        '| ${formatMebibytes(run['rss_peak_bytes']! as int)} '
        '| ${formatMebibytes(run['rss_delta_bytes']! as int)} |',
      );
    }
    buffer.writeln();
  }

  buffer
    ..writeln('## 解释限制')
    ..writeln()
    ..writeln('- RSS 包含 Dart 运行时、SQLite 和依赖库，不等同于 Dart 堆。')
    ..writeln('- 内存为采样观察值，可能漏掉采样间隔内的瞬时尖峰。')
    ..writeln('- 核心链路基准不包含文件选择器、窗口创建和页面首帧绘制。')
    ..writeln('- 建立真实使用反馈前，不根据本报告设置硬性通过阈值。');

  return buffer.toString();
}
