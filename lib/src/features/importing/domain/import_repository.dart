import 'import_record.dart';
import 'successful_import.dart';

abstract interface class ImportRepository {
  Future<ImportRecord?> findCompletedByFingerprint(String fingerprint);

  Future<void> commitSuccessfulImport(
    SuccessfulImport value, {
    Future<void> Function()? beforeCommit,
  });

  Future<void> recordFailure(ImportRecord record);
}
