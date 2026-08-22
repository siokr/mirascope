import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/backup/application/preflight_backup.dart';
import 'package:mirascope/src/features/backup/domain/backup_source_picker.dart';
import 'package:mirascope/src/features/backup/domain/backup_validation.dart';
import 'package:mirascope/src/features/backup/domain/backup_verifier.dart';

void main() {
  test('cancelling the open dialog does not verify a backup', () async {
    final verifier = _Verifier(_manifest());
    final useCase = PreflightBackup(
      sourcePicker: const _Picker(null),
      verifier: verifier,
      currentDatabaseSchemaVersion: 6,
    );

    expect(await useCase(), const PreflightBackupCancelled());
    expect(verifier.paths, isEmpty);
  });

  test('returns a restore preview for a compatible verified backup', () async {
    final verifier = _Verifier(_manifest(databaseSchemaVersion: 4));
    final useCase = PreflightBackup(
      sourcePicker: const _Picker('D:/backup.zip'),
      verifier: verifier,
      currentDatabaseSchemaVersion: 6,
    );

    expect(
      await useCase(),
      isA<PreflightBackupReady>()
          .having((value) => value.sourcePath, 'sourcePath', 'D:/backup.zip')
          .having((value) => value.databaseSchemaVersion, 'schema', 4)
          .having((value) => value.fileCount, 'fileCount', 1),
    );
  });

  test('rejects a backup from a newer database schema', () async {
    final useCase = PreflightBackup(
      sourcePicker: const _Picker('D:/future.zip'),
      verifier: _Verifier(_manifest(databaseSchemaVersion: 7)),
      currentDatabaseSchemaVersion: 6,
    );

    expect(
      await useCase(),
      const PreflightBackupRejected(PreflightBackupFailure.incompatibleVersion),
    );
  });

  test('maps invalid archives to a stable rejection', () async {
    final useCase = PreflightBackup(
      sourcePicker: const _Picker('D:/broken.zip'),
      verifier: _Verifier(
        _manifest(),
        error: const BackupValidationException(
          BackupValidationCode.digestMismatch,
        ),
      ),
      currentDatabaseSchemaVersion: 6,
    );

    expect(
      await useCase(),
      const PreflightBackupRejected(PreflightBackupFailure.invalidBackup),
    );
  });

  test('maps source picker failures to a stable rejection', () async {
    final useCase = PreflightBackup(
      sourcePicker: const _ThrowingPicker(),
      verifier: _Verifier(_manifest()),
      currentDatabaseSchemaVersion: 6,
    );

    expect(
      await useCase(),
      const PreflightBackupRejected(PreflightBackupFailure.invalidBackup),
    );
  });
}

BackupManifest _manifest({int databaseSchemaVersion = 6}) => BackupManifest(
  schemaVersion: 1,
  databaseSchemaVersion: databaseSchemaVersion,
  createdAt: DateTime.utc(2026, 8, 22, 12),
  files: const [
    BackupFileManifest(
      path: 'data/mirascope.sqlite',
      size: 4,
      sha256:
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ],
);

final class _Picker implements BackupSourcePicker {
  const _Picker(this.path);
  final String? path;

  @override
  Future<String?> pickSource() async => path;
}

final class _ThrowingPicker implements BackupSourcePicker {
  const _ThrowingPicker();

  @override
  Future<String?> pickSource() => throw StateError('picker unavailable');
}

final class _Verifier implements BackupVerifier {
  _Verifier(this.manifest, {this.error});
  final BackupManifest manifest;
  final Object? error;
  final paths = <String>[];

  @override
  Future<BackupManifest> verify(String sourcePath) async {
    paths.add(sourcePath);
    if (error case final value?) throw value;
    return manifest;
  }
}
