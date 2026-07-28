import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/effective_reader_preference.dart';
import '../domain/reader_preference.dart' as domain;
import '../domain/reader_preference_defaults.dart';
import '../domain/reader_preference_repository.dart';

final class DriftReaderPreferenceRepository
    implements ReaderPreferenceRepository {
  DriftReaderPreferenceRepository(
    this.database, {
    this.defaults = const ReaderPreferenceDefaults(
      fontSize: 18,
      lineHeight: 1.6,
      themeKey: 'system',
      readingMode: domain.ReadingMode.vertical,
    ),
  });

  final AppDatabase database;
  final ReaderPreferenceDefaults defaults;

  @override
  Future<domain.ReaderPreference?> findGlobal() async {
    final row =
        await (database.select(database.readerPreferences)..where(
              (preference) => preference.scope.equals(
                domain.PreferenceScope.global.storageValue,
              ),
            ))
            .getSingleOrNull();

    return row == null ? null : _toDomain(row);
  }

  @override
  Future<domain.ReaderPreference?> findForMedia(String mediaItemId) async {
    final row =
        await (database.select(database.readerPreferences)..where(
              (preference) =>
                  preference.scope.equals(
                    domain.PreferenceScope.mediaItem.storageValue,
                  ) &
                  preference.mediaItemId.equals(mediaItemId),
            ))
            .getSingleOrNull();

    return row == null ? null : _toDomain(row);
  }

  @override
  Future<EffectiveReaderPreference> resolveForMedia(String mediaItemId) async {
    final mediaPreference = await findForMedia(mediaItemId);
    final globalPreference = await findGlobal();

    return EffectiveReaderPreference(
      fontSize:
          mediaPreference?.fontSize ??
          globalPreference?.fontSize ??
          defaults.fontSize,
      lineHeight:
          mediaPreference?.lineHeight ??
          globalPreference?.lineHeight ??
          defaults.lineHeight,
      themeKey:
          mediaPreference?.themeKey ??
          globalPreference?.themeKey ??
          defaults.themeKey,
      readingMode:
          mediaPreference?.readingMode ??
          globalPreference?.readingMode ??
          defaults.readingMode,
    );
  }

  @override
  Future<void> save(domain.ReaderPreference preference) async {
    _validate(preference);

    await database.customUpdate(
      _upsertStatement(preference.scope),
      variables: [
        Variable.withString(preference.id),
        Variable.withString(preference.scope.storageValue),
        Variable<String>(preference.mediaItemId),
        Variable<double>(preference.fontSize),
        Variable<double>(preference.lineHeight),
        Variable<String>(preference.themeKey),
        Variable<String>(preference.readingMode?.storageValue),
        Variable.withInt(preference.updatedAt.toUtc().millisecondsSinceEpoch),
      ],
      updates: {database.readerPreferences},
    );
  }

  String _upsertStatement(domain.PreferenceScope scope) {
    final conflictTarget = switch (scope) {
      domain.PreferenceScope.global => "(scope) WHERE scope = 'global'",
      domain.PreferenceScope.mediaItem =>
        "(media_item_id) WHERE scope = 'mediaItem'",
    };
    return 'INSERT INTO reader_preferences '
        '(id, scope, media_item_id, font_size, line_height, theme_key, '
        'reading_mode, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?) '
        'ON CONFLICT $conflictTarget DO UPDATE SET '
        'id = excluded.id, '
        'scope = excluded.scope, '
        'media_item_id = excluded.media_item_id, '
        'font_size = excluded.font_size, '
        'line_height = excluded.line_height, '
        'theme_key = excluded.theme_key, '
        'reading_mode = excluded.reading_mode, '
        'updated_at = excluded.updated_at';
  }

  void _validate(domain.ReaderPreference preference) {
    switch (preference.scope) {
      case domain.PreferenceScope.global:
        if (preference.mediaItemId != null) {
          throw ArgumentError.value(
            preference.mediaItemId,
            'preference.mediaItemId',
            'must be null for global preferences',
          );
        }
      case domain.PreferenceScope.mediaItem:
        if (preference.mediaItemId == null ||
            preference.mediaItemId!.trim().isEmpty) {
          throw ArgumentError.value(
            preference.mediaItemId,
            'preference.mediaItemId',
            'must be non-empty for media preferences',
          );
        }
    }
    _validatePositive(preference.fontSize, 'preference.fontSize');
    _validatePositive(preference.lineHeight, 'preference.lineHeight');
  }

  void _validatePositive(double? value, String name) {
    if (value != null && (!value.isFinite || value <= 0)) {
      throw ArgumentError.value(value, name, 'must be positive');
    }
  }

  domain.ReaderPreference _toDomain(ReaderPreference row) {
    return domain.ReaderPreference(
      id: row.id,
      scope: domain.PreferenceScope.fromStorageValue(row.scope),
      mediaItemId: row.mediaItemId,
      fontSize: row.fontSize,
      lineHeight: row.lineHeight,
      themeKey: row.themeKey,
      readingMode: row.readingMode == null
          ? null
          : domain.ReadingMode.fromStorageValue(row.readingMode!),
      updatedAt: row.updatedAt,
    );
  }
}
