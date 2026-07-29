import 'app_error_code.dart';

final class AppFailure implements Exception {
  const AppFailure({required this.code, required this.message, this.recovery});

  AppFailure.fromCode(AppErrorCode code)
    : this(code: code.value, message: code.message, recovery: code.recovery);

  final String code;
  final String message;
  final String? recovery;

  @override
  String toString() => 'AppFailure($code)';
}

AppFailure mapToAppFailure(Object error, {required AppErrorCode fallback}) {
  if (error case final AppFailure failure) {
    return failure;
  }
  return AppFailure.fromCode(fallback);
}
