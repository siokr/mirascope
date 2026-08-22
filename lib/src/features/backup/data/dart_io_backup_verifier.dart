import 'dart:io';
import 'dart:typed_data';

import '../domain/backup_validation.dart';
import '../domain/backup_verifier.dart';
import 'backup_archive_validator.dart';

final class DartIoBackupVerifier implements BackupVerifier {
  const DartIoBackupVerifier({this.validator = const BackupArchiveValidator()});

  final BackupArchiveValidator validator;

  @override
  Future<BackupManifest> verify(String sourcePath) async {
    final bytes = await File(sourcePath).readAsBytes();
    return validator.validate(Uint8List.fromList(bytes));
  }
}
