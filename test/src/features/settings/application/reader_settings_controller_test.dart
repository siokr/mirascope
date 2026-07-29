import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/ids/id_generator.dart';
import 'package:mirascope/src/features/settings/application/reader_settings_controller.dart';
import 'package:mirascope/src/features/settings/domain/effective_reader_preference.dart';
import 'package:mirascope/src/features/settings/domain/reader_preference.dart';
import 'package:mirascope/src/features/settings/domain/reader_preference_repository.dart';

void main() {
  test('updates preview immediately and persists a media override', () async {
    final repository = _Repository();
    final controller = _controller(repository);
    addTearDown(controller.dispose);
    await controller.initialize();

    controller.setFontSize(24);

    expect(controller.preference.fontSize, 24);
    await Future<void>.delayed(Duration.zero);
    expect(repository.saved.last.fontSize, 24);
    expect(repository.saved.last.mediaItemId, 'media-1');
  });

  test('save failure restores the previous effective value', () async {
    final repository = _Repository(failSave: true);
    final controller = _controller(repository);
    addTearDown(controller.dispose);
    await controller.initialize();

    controller.setTheme('sepia');
    expect(controller.preference.themeKey, 'sepia');
    await Future<void>.delayed(Duration.zero);

    expect(controller.preference.themeKey, 'system');
    expect(controller.errorMessage, '无法保存阅读设置');
  });

  test('reset saves an empty override and resolves inherited values', () async {
    final repository = _Repository(
      initial: const EffectiveReaderPreference(
        fontSize: 24,
        lineHeight: 2,
        themeKey: 'dark',
        readingMode: ReadingMode.vertical,
      ),
      inherited: const EffectiveReaderPreference(
        fontSize: 18,
        lineHeight: 1.6,
        themeKey: 'light',
        readingMode: ReadingMode.vertical,
      ),
    );
    final controller = _controller(repository);
    addTearDown(controller.dispose);
    await controller.initialize();

    await controller.resetToInherited();

    expect(repository.saved.last.fontSize, isNull);
    expect(repository.saved.last.themeKey, isNull);
    expect(controller.preference.themeKey, 'light');
  });
}

ReaderSettingsController _controller(_Repository repository) {
  return ReaderSettingsController(
    mediaItemId: 'media-1',
    repository: repository,
    idGenerator: _Ids(),
    clock: () => DateTime.utc(2026, 7, 29),
  );
}

final class _Ids implements IdGenerator {
  var value = 0;
  @override
  String newId() => 'id-${value++}';
}

final class _Repository implements ReaderPreferenceRepository {
  _Repository({
    this.failSave = false,
    this.initial = const EffectiveReaderPreference(
      fontSize: 18,
      lineHeight: 1.6,
      themeKey: 'system',
      readingMode: ReadingMode.vertical,
    ),
    EffectiveReaderPreference? inherited,
  }) : inherited = inherited ?? initial;

  final bool failSave;
  final EffectiveReaderPreference initial;
  final EffectiveReaderPreference inherited;
  final saved = <ReaderPreference>[];

  @override
  Future<EffectiveReaderPreference> resolveForMedia(String mediaItemId) async =>
      saved.isEmpty ? initial : inherited;

  @override
  Future<EffectiveReaderPreference> resolveGlobal() async =>
      saved.isEmpty ? initial : inherited;

  @override
  Future<void> save(ReaderPreference preference) async {
    if (failSave) throw StateError('failed');
    saved.add(preference);
  }

  @override
  Future<ReaderPreference?> findForMedia(String mediaItemId) async => null;

  @override
  Future<ReaderPreference?> findGlobal() async => null;
}
