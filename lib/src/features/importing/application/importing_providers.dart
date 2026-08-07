import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/ids/id_generator.dart';
import '../data/charset_converter_gb18030_decoder.dart';
import '../data/dart_io_derived_txt_store.dart';
import '../data/dart_io_derived_epub_store.dart';
import '../data/dart_io_epub_container.dart';
import '../data/dart_io_epub_source_inspector.dart';
import '../data/dart_io_txt_source_inspector.dart';
import '../data/dart_io_txt_source_reader.dart';
import '../data/file_selector_txt_file_picker.dart';
import '../data/file_selector_epub_file_picker.dart';
import '../domain/epub_file_picker.dart';
import '../domain/derived_epub_store.dart';
import '../domain/epub_source_candidate.dart';
import '../domain/txt_encoding.dart';
import '../domain/derived_txt_store.dart';
import '../domain/txt_file_picker.dart';
import '../domain/txt_source_candidate.dart';
import '../domain/txt_source_reader.dart';
import 'decode_txt_source.dart';
import 'import_epub.dart';
import 'import_txt.dart';
import 'normalize_epub_content.dart';
import 'parse_epub_package.dart';
import 'prepare_epub_source.dart';
import 'prepare_txt_source.dart';
import 'relocate_txt_source.dart';
import 'relocate_epub_source.dart';
import 'txt_chapter_detector.dart';
import 'txt_decoder.dart';

final txtFilePickerProvider = Provider<TxtFilePicker>((ref) {
  return const FileSelectorTxtFilePicker();
});

final txtSourceInspectorProvider = Provider<TxtSourceInspector>((ref) {
  return DartIoTxtSourceInspector();
});

final epubFilePickerProvider = Provider<EpubFilePicker>((ref) {
  return const FileSelectorEpubFilePicker();
});

final epubSourceInspectorProvider = Provider<EpubSourceInspector>((ref) {
  return DartIoEpubSourceInspector();
});

final txtSourceReaderProvider = Provider<TxtSourceReader>((ref) {
  return DartIoTxtSourceReader();
});

final gb18030DecoderProvider = Provider<Gb18030Decoder>((ref) {
  return const CharsetConverterGb18030Decoder();
});

final txtDecoderProvider = Provider<TxtDecoder>((ref) {
  return TxtDecoder(gb18030Decoder: ref.watch(gb18030DecoderProvider));
});

final decodeTxtSourceProvider = Provider<DecodeTxtSource>((ref) {
  return DecodeTxtSource(
    sourceReader: ref.watch(txtSourceReaderProvider),
    decoder: ref.watch(txtDecoderProvider),
  );
});

final txtChapterDetectorProvider = Provider<TxtChapterDetector>((ref) {
  return const TxtChapterDetector();
});

final importIdGeneratorProvider = Provider<IdGenerator>((ref) {
  return const UuidIdGenerator();
});

final importClockProvider = Provider<ImportClock>((ref) {
  return () => DateTime.now().toUtc();
});

final derivedTxtStoreProvider = FutureProvider<DerivedTxtStore>((ref) async {
  final supportDirectory = await getApplicationSupportDirectory();
  return DartIoDerivedTxtStore(
    Directory('${supportDirectory.path}${Platform.pathSeparator}derived_txt'),
  );
});

final derivedEpubStoreProvider = FutureProvider<DerivedEpubStore>((ref) async {
  final supportDirectory = await getApplicationSupportDirectory();
  return DartIoDerivedEpubStore(
    Directory('${supportDirectory.path}${Platform.pathSeparator}derived_epub'),
  );
});

final epubContainerFactoryProvider = Provider<EpubContainerFactory>((ref) {
  return (path) => DartIoEpubContainer.open(path);
});

final parseEpubPackageProvider = Provider<ParseEpubPackage>((ref) {
  return const ParseEpubPackage();
});

final normalizeEpubContentProvider = Provider<NormalizeEpubContent>((ref) {
  return const NormalizeEpubContent();
});

final importEpubProvider = FutureProvider<ImportEpub>((ref) async {
  return ImportEpub(
    openContainer: ref.watch(epubContainerFactoryProvider),
    parsePackage: ref.watch(parseEpubPackageProvider).call,
    normalizeContent: ref.watch(normalizeEpubContentProvider).call,
    importRepository: ref.watch(importRepositoryProvider),
    derivedEpubStore: await ref.watch(derivedEpubStoreProvider.future),
    idGenerator: ref.watch(importIdGeneratorProvider),
    clock: ref.watch(importClockProvider),
  );
});

final importTxtProvider = FutureProvider<ImportTxt>((ref) async {
  return ImportTxt(
    decodeTxtSource: ref.watch(decodeTxtSourceProvider),
    chapterDetector: ref.watch(txtChapterDetectorProvider),
    importRepository: ref.watch(importRepositoryProvider),
    derivedTxtStore: await ref.watch(derivedTxtStoreProvider.future),
    idGenerator: ref.watch(importIdGeneratorProvider),
    clock: ref.watch(importClockProvider),
  );
});

final prepareTxtSourceProvider = Provider<PrepareTxtSource>((ref) {
  return PrepareTxtSource(
    filePicker: ref.watch(txtFilePickerProvider),
    sourceInspector: ref.watch(txtSourceInspectorProvider),
    importRepository: ref.watch(importRepositoryProvider),
  );
});

final prepareEpubSourceProvider = Provider<PrepareEpubSource>((ref) {
  return PrepareEpubSource(
    filePicker: ref.watch(epubFilePickerProvider),
    sourceInspector: ref.watch(epubSourceInspectorProvider),
    importRepository: ref.watch(importRepositoryProvider),
  );
});

final relocateTxtSourceProvider = Provider<RelocateTxtSource>((ref) {
  return RelocateTxtSource(
    filePicker: ref.watch(txtFilePickerProvider),
    sourceInspector: ref.watch(txtSourceInspectorProvider),
    repository: ref.watch(sourceRelocationRepositoryProvider),
  );
});

final relocateEpubSourceProvider = Provider<RelocateEpubSource>((ref) {
  return RelocateEpubSource(
    filePicker: ref.watch(epubFilePickerProvider),
    sourceInspector: ref.watch(epubSourceInspectorProvider),
    repository: ref.watch(sourceRelocationRepositoryProvider),
  );
});
