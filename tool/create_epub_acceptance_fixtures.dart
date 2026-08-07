import 'dart:io';

import '../test/support/epub_test_fixture.dart';

Future<void> main(List<String> arguments) async {
  final output = Directory(
    arguments.isEmpty ? 'build/acceptance/epub' : arguments.single,
  );
  await output.create(recursive: true);
  await File(
    '${output.path}/mirascope-epub2.epub',
  ).writeAsBytes(buildTestEpub(TestEpubVersion.epub2), flush: true);
  await File(
    '${output.path}/mirascope-epub3.epub',
  ).writeAsBytes(buildTestEpub(TestEpubVersion.epub3), flush: true);
  stdout.writeln(output.absolute.path);
}
