import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/database/app_database.dart'
    hide ReaderPreference;
import 'package:mirascope/src/features/settings/data/drift_reader_preference_repository.dart';
import 'package:mirascope/src/features/settings/domain/reader_preference.dart';

import '../../../core/database/database_test_support.dart';

final _now = DateTime.utc(2026, 7, 28, 12);

void main() {
  test('missing preferences resolve to program defaults', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftReaderPreferenceRepository(database);

    final effective = await repository.resolveForMedia('media-one');

    expect(effective.fontSize, 18);
    expect(effective.lineHeight, 1.6);
    expect(effective.themeKey, 'system');
    expect(effective.readingMode, ReadingMode.vertical);
  });

  test('global non-null values override program defaults', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftReaderPreferenceRepository(database);
    await repository.save(
      _preference(
        id: 'global-one',
        scope: PreferenceScope.global,
        fontSize: 20,
        themeKey: 'sepia',
      ),
    );

    final stored = await repository.findGlobal();
    final effective = await repository.resolveForMedia('media-one');

    expect(stored?.id, 'global-one');
    expect(stored?.scope, PreferenceScope.global);
    expect(stored?.mediaItemId, isNull);
    expect(stored?.fontSize, 20);
    expect(stored?.lineHeight, isNull);
    expect(stored?.themeKey, 'sepia');
    expect(stored?.readingMode, isNull);
    expect(effective.fontSize, 20);
    expect(effective.lineHeight, 1.6);
    expect(effective.themeKey, 'sepia');
    expect(effective.readingMode, ReadingMode.vertical);
  });

  test(
    'media values fall back field by field to global then defaults',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      await _insertMedia(database);
      final repository = DriftReaderPreferenceRepository(database);
      await repository.save(
        _preference(
          id: 'global-one',
          scope: PreferenceScope.global,
          fontSize: 20,
          lineHeight: 1.8,
          themeKey: 'sepia',
        ),
      );
      await repository.save(
        _preference(
          id: 'media-one-preference',
          scope: PreferenceScope.mediaItem,
          mediaItemId: 'media-one',
          lineHeight: 2,
          themeKey: 'night',
        ),
      );

      final stored = await repository.findForMedia('media-one');
      final effective = await repository.resolveForMedia('media-one');

      expect(stored?.id, 'media-one-preference');
      expect(stored?.scope, PreferenceScope.mediaItem);
      expect(stored?.mediaItemId, 'media-one');
      expect(stored?.fontSize, isNull);
      expect(stored?.lineHeight, 2);
      expect(stored?.themeKey, 'night');
      expect(effective.fontSize, 20);
      expect(effective.lineHeight, 2);
      expect(effective.themeKey, 'night');
      expect(effective.readingMode, ReadingMode.vertical);
    },
  );

  test(
    'save upserts global and media preferences by their scope keys',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      await _insertMedia(database);
      final repository = DriftReaderPreferenceRepository(database);
      await repository.save(
        _preference(
          id: 'global-one',
          scope: PreferenceScope.global,
          fontSize: 19,
        ),
      );
      await repository.save(
        _preference(
          id: 'global-one',
          scope: PreferenceScope.global,
          fontSize: 21,
        ),
      );
      await repository.save(
        _preference(
          id: 'media-one-preference',
          scope: PreferenceScope.mediaItem,
          mediaItemId: 'media-one',
          lineHeight: 1.7,
        ),
      );
      await repository.save(
        _preference(
          id: 'media-one-preference',
          scope: PreferenceScope.mediaItem,
          mediaItemId: 'media-one',
          lineHeight: 1.9,
        ),
      );

      final rows = await database.select(database.readerPreferences).get();
      final global = await repository.findGlobal();
      final media = await repository.findForMedia('media-one');

      expect(rows, hasLength(2));
      expect(global?.fontSize, 21);
      expect(media?.lineHeight, 1.9);
    },
  );

  test('invalid preferences are rejected before database access', () async {
    final database = createTestDatabase();
    await database.close();
    final repository = DriftReaderPreferenceRepository(database);
    final invalidPreferences = [
      _preference(
        id: 'global-with-media',
        scope: PreferenceScope.global,
        mediaItemId: 'media-one',
      ),
      _preference(id: 'media-without-id', scope: PreferenceScope.mediaItem),
      _preference(
        id: 'media-with-blank-id',
        scope: PreferenceScope.mediaItem,
        mediaItemId: '   ',
      ),
      _preference(id: 'zero-font', scope: PreferenceScope.global, fontSize: 0),
      _preference(
        id: 'negative-font',
        scope: PreferenceScope.global,
        fontSize: -1,
      ),
      _preference(
        id: 'zero-line-height',
        scope: PreferenceScope.global,
        lineHeight: 0,
      ),
      _preference(
        id: 'negative-line-height',
        scope: PreferenceScope.global,
        lineHeight: -1,
      ),
    ];

    for (final preference in invalidPreferences) {
      await expectLater(repository.save(preference), throwsArgumentError);
    }
  });
}

ReaderPreference _preference({
  required String id,
  required PreferenceScope scope,
  String? mediaItemId,
  double? fontSize,
  double? lineHeight,
  String? themeKey,
  ReadingMode? readingMode,
}) {
  return ReaderPreference(
    id: id,
    scope: scope,
    mediaItemId: mediaItemId,
    fontSize: fontSize,
    lineHeight: lineHeight,
    themeKey: themeKey,
    readingMode: readingMode,
    updatedAt: _now,
  );
}

Future<void> _insertMedia(AppDatabase database) async {
  await database
      .into(database.mediaItems)
      .insert(
        MediaItemsCompanion.insert(
          id: 'media-one',
          mediaType: 'novel',
          title: 'Title one',
          createdAt: _now,
          updatedAt: _now,
        ),
      );
}
