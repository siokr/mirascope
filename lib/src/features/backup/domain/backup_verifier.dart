import 'backup_validation.dart';

abstract interface class BackupVerifier {
  Future<BackupManifest> verify(String sourcePath);
}
