import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/ids/id_generator.dart';
import '../domain/effective_reader_preference.dart';
import '../domain/reader_preference.dart';
import '../domain/reader_preference_repository.dart';

typedef ReaderSettingsClock = DateTime Function();

final class ReaderSettingsController extends ChangeNotifier {
  ReaderSettingsController({
    this.mediaItemId,
    required this.repository,
    required this.idGenerator,
    required this.clock,
  });

  final String? mediaItemId;
  final ReaderPreferenceRepository repository;
  final IdGenerator idGenerator;
  final ReaderSettingsClock clock;

  late EffectiveReaderPreference preference;
  String? errorMessage;
  Future<void> _saveQueue = Future.value();
  var _revision = 0;

  Future<void> initialize() async {
    preference = mediaItemId == null
        ? await repository.resolveGlobal()
        : await repository.resolveForMedia(mediaItemId!);
  }

  void setFontSize(double value) => _optimisticSave(
    EffectiveReaderPreference(
      fontSize: value,
      lineHeight: preference.lineHeight,
      themeKey: preference.themeKey,
      readingMode: preference.readingMode,
    ),
  );

  void setLineHeight(double value) => _optimisticSave(
    EffectiveReaderPreference(
      fontSize: preference.fontSize,
      lineHeight: value,
      themeKey: preference.themeKey,
      readingMode: preference.readingMode,
    ),
  );

  void setTheme(String value) => _optimisticSave(
    EffectiveReaderPreference(
      fontSize: preference.fontSize,
      lineHeight: preference.lineHeight,
      themeKey: value,
      readingMode: preference.readingMode,
    ),
  );

  Future<void> resetToInherited() async {
    final previous = preference;
    final revision = ++_revision;
    errorMessage = null;
    notifyListeners();
    try {
      await _saveQueue;
      await repository.save(
        ReaderPreference(
          id: idGenerator.newId(),
          scope: mediaItemId == null
              ? PreferenceScope.global
              : PreferenceScope.mediaItem,
          mediaItemId: mediaItemId,
          updatedAt: clock().toUtc(),
        ),
      );
      final resolved = mediaItemId == null
          ? await repository.resolveGlobal()
          : await repository.resolveForMedia(mediaItemId!);
      if (revision == _revision) {
        preference = resolved;
        notifyListeners();
      }
    } on Object {
      if (revision == _revision) {
        preference = previous;
        errorMessage = '无法保存阅读设置';
        notifyListeners();
      }
    }
  }

  void _optimisticSave(EffectiveReaderPreference next) {
    final previous = preference;
    preference = next;
    errorMessage = null;
    final revision = ++_revision;
    notifyListeners();
    _saveQueue = _saveQueue.then((_) async {
      try {
        await repository.save(
          ReaderPreference(
            id: idGenerator.newId(),
            scope: mediaItemId == null
                ? PreferenceScope.global
                : PreferenceScope.mediaItem,
            mediaItemId: mediaItemId,
            fontSize: next.fontSize,
            lineHeight: next.lineHeight,
            themeKey: next.themeKey,
            readingMode: next.readingMode,
            updatedAt: clock().toUtc(),
          ),
        );
      } on Object {
        if (revision == _revision) {
          preference = previous;
          errorMessage = '无法保存阅读设置';
          notifyListeners();
        }
      }
    });
    unawaited(_saveQueue);
  }
}
