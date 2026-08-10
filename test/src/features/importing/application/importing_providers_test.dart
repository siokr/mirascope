import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart';
import 'package:mirascope/src/core/database/database_providers.dart';
import 'package:mirascope/src/features/importing/application/importing_providers.dart';
import 'package:mirascope/src/features/importing/data/charset_converter_gb18030_decoder.dart';
import 'package:mirascope/src/features/importing/data/dart_io_epub_source_inspector.dart';
import 'package:mirascope/src/features/importing/data/dart_io_manga_source_inspector.dart';
import 'package:mirascope/src/features/importing/data/dart_io_txt_source_inspector.dart';
import 'package:mirascope/src/features/importing/data/dart_io_txt_source_reader.dart';
import 'package:mirascope/src/features/importing/data/file_selector_epub_file_picker.dart';
import 'package:mirascope/src/features/importing/data/file_selector_manga_source_picker.dart';
import 'package:mirascope/src/features/importing/data/file_selector_txt_file_picker.dart';
import 'package:mirascope/src/features/importing/data/drift_import_repository.dart';

void main() {
  test(
    'production providers assemble picker inspector and repository',
    () async {
      final database = AppDatabase.inMemory();
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);
      addTearDown(database.close);

      final useCase = container.read(prepareTxtSourceProvider);

      expect(useCase.filePicker, isA<FileSelectorTxtFilePicker>());
      expect(useCase.sourceInspector, isA<DartIoTxtSourceInspector>());
      expect(useCase.importRepository, isA<DriftImportRepository>());
      expect(
        (useCase.importRepository as DriftImportRepository).database,
        same(database),
      );
      final decodeUseCase = container.read(decodeTxtSourceProvider);
      expect(decodeUseCase.sourceReader, isA<DartIoTxtSourceReader>());
      expect(
        decodeUseCase.decoder.gb18030Decoder,
        isA<CharsetConverterGb18030Decoder>(),
      );
      final epubUseCase = container.read(prepareEpubSourceProvider);
      expect(epubUseCase.filePicker, isA<FileSelectorEpubFilePicker>());
      expect(epubUseCase.sourceInspector, isA<DartIoEpubSourceInspector>());
      expect(epubUseCase.importRepository, same(useCase.importRepository));
      final mangaUseCase = container.read(prepareMangaSourceProvider);
      expect(mangaUseCase.sourcePicker, isA<FileSelectorMangaSourcePicker>());
      expect(mangaUseCase.sourceInspector, isA<DartIoMangaSourceInspector>());
      expect(mangaUseCase.importRepository, same(useCase.importRepository));
    },
  );
}
