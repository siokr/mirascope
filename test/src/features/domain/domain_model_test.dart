import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/importing/domain/import_record.dart';
import 'package:mirascope/src/features/library/domain/media_item.dart';
import 'package:mirascope/src/features/novel/domain/content_unit.dart';
import 'package:mirascope/src/features/settings/domain/reader_preference.dart';

void main() {
  test('domain enums use stable storage values', () {
    expect(MediaType.novel.storageValue, 'novel');
    expect(ContentUnitType.chapter.storageValue, 'chapter');
    expect(ImportStatus.completed.storageValue, 'completed');
    expect(PreferenceScope.mediaItem.storageValue, 'mediaItem');
    expect(ReadingMode.vertical.storageValue, 'vertical');
  });

  test('domain enums reject unknown storage values', () {
    expect(
      () => MediaType.fromStorageValue('podcast'),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => ContentUnitType.fromStorageValue('section'),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => ImportStatus.fromStorageValue('cancelled'),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => PreferenceScope.fromStorageValue('library'),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => ReadingMode.fromStorageValue('paged'),
      throwsA(isA<ArgumentError>()),
    );
  });
}
