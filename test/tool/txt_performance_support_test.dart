import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/txt_performance_support.dart';

void main() {
  test(
    'generated sample has the exact requested size and readable headings',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'mirascope_sample_test_',
      );
      addTearDown(() async => root.delete(recursive: true));
      final file = File('${root.path}${Platform.pathSeparator}sample.txt');
      const sample = TxtBenchmarkSample('test', 4096);

      await generateTxtBenchmarkSample(file, sample);

      expect(await file.length(), sample.targetBytes);
      expect(await file.readAsString(), startsWith('Chapter 000001 test\n'));
    },
  );

  test('generated chapters are spaced at 64 KiB boundaries', () async {
    final root = await Directory.systemTemp.createTemp(
      'mirascope_sample_test_',
    );
    addTearDown(() async => root.delete(recursive: true));
    final file = File('${root.path}${Platform.pathSeparator}sample.txt');
    const sample = TxtBenchmarkSample('test', 128 * 1024);

    await generateTxtBenchmarkSample(file, sample);
    final text = await file.readAsString();

    expect(text.indexOf('Chapter 000002 test\n'), 64 * 1024);
    expect(
      RegExp(r'^Chapter ', multiLine: true).allMatches(text),
      hasLength(2),
    );
  });

  test('median uses the middle value without averaging measurements', () {
    expect(medianInt([30, 10, 20]), 20);
    expect(medianInt([40, 10, 30, 20]), 30);
    expect(() => medianInt(const []), throwsArgumentError);
  });

  test('markdown report contains metrics without private paths or body', () {
    final report = <String, Object?>{
      'environment': <String, Object?>{
        'date': '2026-07-29T00:00:00Z',
        'git_commit': 'abc123',
        'operating_system': 'windows',
        'cpu': 'test cpu',
        'processors': 8,
        'total_memory': '16384 MiB',
        'flutter_version': '3.44.8',
        'dart_version': '3.12.2',
        'build_mode': 'Dart AOT executable',
      },
      'samples': <Object?>[
        <String, Object?>{
          'name': 'small',
          'bytes': 1024,
          'sha256': 'safe-hash',
          'median': <String, Object?>{
            'chapter_count': 2,
            'import_us': 1000,
            'open_us': 2000,
            'switch_us': 3000,
            'rss_peak_bytes': 4 * 1024 * 1024,
            'rss_delta_bytes': 1024 * 1024,
          },
          'runs': <Object?>[
            <String, Object?>{
              'import_us': 1000,
              'open_us': 2000,
              'switch_us': 3000,
              'rss_start_bytes': 3 * 1024 * 1024,
              'rss_peak_bytes': 4 * 1024 * 1024,
              'rss_delta_bytes': 1024 * 1024,
            },
          ],
        },
      ],
    };

    final markdown = renderTxtBenchmarkMarkdown(report);

    expect(markdown, contains('small'));
    expect(markdown, contains('safe-hash'));
    expect(markdown, contains('1.000 ms'));
    expect(markdown, isNot(contains(r'C:\Users')));
    expect(markdown, isNot(contains('generated benchmark text')));
  });
}
