import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/core/ids/id_generator.dart';
import 'package:mirascope/src/features/importing/application/decode_txt_source.dart';
import 'package:mirascope/src/features/importing/application/import_txt.dart';
import 'package:mirascope/src/features/importing/application/txt_chapter_detector.dart';
import 'package:mirascope/src/features/importing/application/txt_decoder.dart';
import 'package:mirascope/src/features/importing/data/dart_io_derived_txt_store.dart';
import 'package:mirascope/src/features/importing/data/dart_io_txt_source_inspector.dart';
import 'package:mirascope/src/features/importing/data/dart_io_txt_source_reader.dart';
import 'package:mirascope/src/features/importing/data/drift_import_repository.dart';
import 'package:mirascope/src/features/importing/domain/txt_encoding.dart';
import 'package:mirascope/src/features/novel/data/dart_io_novel_reader_repository.dart';

import 'src/txt_performance_support.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--worker')) {
    await _runWorker(arguments);
    return;
  }
  await _runController(arguments);
}

Future<void> _runController(List<String> arguments) async {
  final flutterVersion = _argument(arguments, '--flutter-version');
  if (flutterVersion == null || flutterVersion.trim().isEmpty) {
    stderr.writeln('Missing required --flutter-version value.');
    exitCode = 64;
    return;
  }

  final outputDirectory = Directory(
    _argument(arguments, '--output') ?? 'docs/performance',
  );
  final temporary = await Directory.systemTemp.createTemp(
    'mirascope_txt_benchmark_',
  );

  try {
    final sampleDirectory = Directory(
      '${temporary.path}${Platform.pathSeparator}samples',
    );
    final sampleReports = <Map<String, Object?>>[];

    for (final sample in txtBenchmarkSamples) {
      final sampleFile = File(
        '${sampleDirectory.path}${Platform.pathSeparator}${sample.name}.txt',
      );
      await generateTxtBenchmarkSample(sampleFile, sample);
      final digest = await sha256.bind(sampleFile.openRead()).single;

      await _launchWorker(sample, sampleFile, temporary, warmup: true);
      final runs = <Map<String, Object?>>[];
      for (var index = 0; index < 3; index++) {
        runs.add(
          await _launchWorker(sample, sampleFile, temporary, warmup: false),
        );
      }

      sampleReports.add({
        'name': sample.name,
        'bytes': await sampleFile.length(),
        'sha256': digest.toString(),
        'runs': runs,
        'median': _medianRun(runs),
      });
    }

    final environment = await _environment(flutterVersion);
    final report = <String, Object?>{
      'schema_version': 1,
      'environment': environment,
      'samples': sampleReports,
    };

    await outputDirectory.create(recursive: true);
    final date = (environment['date']! as String).substring(0, 10);
    final jsonFile = File(
      '${outputDirectory.path}${Platform.pathSeparator}'
      '$date-txt-baseline.json',
    );
    final markdownFile = File(
      '${outputDirectory.path}${Platform.pathSeparator}'
      '$date-txt-baseline.md',
    );
    await jsonFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(report),
      flush: true,
    );
    await markdownFile.writeAsString(
      renderTxtBenchmarkMarkdown(report),
      flush: true,
    );
    stdout.writeln(
      jsonEncode({'json': jsonFile.path, 'markdown': markdownFile.path}),
    );
  } finally {
    if (await temporary.exists()) {
      await temporary.delete(recursive: true);
    }
  }
}

Future<Map<String, Object?>> _launchWorker(
  TxtBenchmarkSample sample,
  File sampleFile,
  Directory temporary, {
  required bool warmup,
}) async {
  final runsDirectory = await Directory(
    '${temporary.path}${Platform.pathSeparator}runs',
  ).create(recursive: true);
  final runRoot = await runsDirectory.createTemp('${sample.name}_');
  final executable = Platform.resolvedExecutable;
  final runningAot = !RegExp(
    r'(^|[\\/])dart(\.exe)?$',
    caseSensitive: false,
  ).hasMatch(executable);
  final workerArguments = [
    if (!runningAot) Platform.script.toFilePath(),
    '--worker',
    '--sample',
    sample.name,
    '--source',
    sampleFile.path,
    '--root',
    runRoot.path,
  ];
  final result = await Process.run(executable, workerArguments);
  if (result.exitCode != 0) {
    throw StateError(
      'Benchmark worker failed for ${sample.name}: ${result.stderr}',
    );
  }
  if (warmup) {
    return const <String, Object?>{};
  }
  final lines = (result.stdout as String)
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .toList();
  if (lines.length != 1) {
    throw const FormatException('Worker must emit exactly one JSON line.');
  }
  return (jsonDecode(lines.single) as Map<String, Object?>);
}

Future<void> _runWorker(List<String> arguments) async {
  final sampleName = _requiredArgument(arguments, '--sample');
  final sourcePath = _requiredArgument(arguments, '--source');
  final rootPath = _requiredArgument(arguments, '--root');
  final root = Directory(rootPath);
  final database = AppDatabase.inMemory();
  final baselineRss = ProcessInfo.currentRss;
  var peakRss = baselineRss;
  final sampler = Timer.periodic(const Duration(milliseconds: 2), (_) {
    final current = ProcessInfo.currentRss;
    if (current > peakRss) peakRss = current;
  });

  try {
    final importWatch = Stopwatch()..start();
    final candidate = await DartIoTxtSourceInspector().inspect(sourcePath);
    final result = await ImportTxt(
      decodeTxtSource: DecodeTxtSource(
        sourceReader: DartIoTxtSourceReader(),
        decoder: const TxtDecoder(gb18030Decoder: _UnusedGb18030Decoder()),
      ),
      chapterDetector: const TxtChapterDetector(),
      importRepository: DriftImportRepository(database),
      derivedTxtStore: DartIoDerivedTxtStore(root),
      idGenerator: _SequentialIds(sampleName),
      clock: () => DateTime.now().toUtc(),
    )(candidate: candidate, title: 'Benchmark $sampleName');
    importWatch.stop();
    if (result is! TxtImportSucceeded) {
      throw StateError('Import did not succeed: ${result.runtimeType}');
    }

    final reader = DartIoNovelReaderRepository(database, root);
    final openWatch = Stopwatch()..start();
    final book = await reader.loadBook(result.mediaItemId);
    if (book == null || book.chapters.isEmpty) {
      throw StateError('Imported book has no chapters.');
    }
    await reader.readChapter(book.chapters.first);
    openWatch.stop();

    final switchWatch = Stopwatch()..start();
    await reader.readChapter(
      book.chapters.length > 1 ? book.chapters[1] : book.chapters.first,
    );
    switchWatch.stop();
    await Future<void>.delayed(const Duration(milliseconds: 5));
    peakRss = peakRss < ProcessInfo.currentRss
        ? ProcessInfo.currentRss
        : peakRss;

    stdout.writeln(
      jsonEncode({
        'import_us': importWatch.elapsedMicroseconds,
        'open_us': openWatch.elapsedMicroseconds,
        'switch_us': switchWatch.elapsedMicroseconds,
        'chapter_count': book.chapters.length,
        'rss_start_bytes': baselineRss,
        'rss_peak_bytes': peakRss,
        'rss_delta_bytes': peakRss - baselineRss,
        'fingerprint': candidate.fingerprint,
      }),
    );
  } finally {
    sampler.cancel();
    await database.close();
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  }
}

Map<String, Object?> _medianRun(List<Map<String, Object?>> runs) {
  int median(String key) => medianInt(runs.map((run) => run[key]! as int));
  return {
    'import_us': median('import_us'),
    'open_us': median('open_us'),
    'switch_us': median('switch_us'),
    'chapter_count': median('chapter_count'),
    'rss_start_bytes': median('rss_start_bytes'),
    'rss_peak_bytes': median('rss_peak_bytes'),
    'rss_delta_bytes': median('rss_delta_bytes'),
  };
}

Future<Map<String, Object?>> _environment(String flutterVersion) async {
  final git = await Process.run('git', ['rev-parse', 'HEAD']);
  final memory = await _totalMemory();
  final cpu = await _cpuName();
  return {
    'date': DateTime.now().toUtc().toIso8601String(),
    'git_commit': (git.stdout as String).trim(),
    'operating_system':
        '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
    'cpu': cpu ?? Platform.environment['PROCESSOR_IDENTIFIER'] ?? 'unavailable',
    'processors': Platform.numberOfProcessors,
    'total_memory': memory == null
        ? 'unavailable'
        : '${formatMebibytes(memory)} MiB',
    'flutter_version': flutterVersion,
    'dart_version': Platform.version.split(' ').first,
    'build_mode': 'Dart AOT executable',
  };
}

Future<int?> _totalMemory() async {
  if (Platform.isWindows) {
    final value = await _windowsCimValue(
      '(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory',
    );
    return int.tryParse(value ?? '');
  } else if (Platform.isLinux) {
    final text = await File('/proc/meminfo').readAsString();
    final match = RegExp(r'MemTotal:\s+(\d+)\s+kB').firstMatch(text);
    if (match != null) return int.parse(match.group(1)!) * 1024;
  }
  return null;
}

Future<String?> _cpuName() async {
  if (!Platform.isWindows) return null;
  return _windowsCimValue('(Get-CimInstance Win32_Processor).Name');
}

Future<String?> _windowsCimValue(String expression) async {
  final result = await Process.run('powershell', [
    '-NoProfile',
    '-NonInteractive',
    '-Command',
    expression,
  ]);
  if (result.exitCode != 0) return null;
  final value = (result.stdout as String).trim();
  return value.isEmpty ? null : value;
}

String? _argument(List<String> arguments, String name) {
  final index = arguments.indexOf(name);
  return index >= 0 && index + 1 < arguments.length
      ? arguments[index + 1]
      : null;
}

String _requiredArgument(List<String> arguments, String name) {
  final value = _argument(arguments, name);
  if (value == null || value.isEmpty) {
    throw ArgumentError('Missing $name');
  }
  return value;
}

final class _SequentialIds implements IdGenerator {
  _SequentialIds(this.prefix);

  final String prefix;
  var _next = 0;

  @override
  String newId() => '${prefix}_${_next++}';
}

final class _UnusedGb18030Decoder implements Gb18030Decoder {
  const _UnusedGb18030Decoder();

  @override
  Future<String> decode(List<int> bytes) {
    throw UnsupportedError('Generated benchmark samples are UTF-8.');
  }
}
