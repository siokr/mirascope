import 'package:uuid/uuid.dart';

abstract interface class IdGenerator {
  String newId();
}

final class UuidIdGenerator implements IdGenerator {
  const UuidIdGenerator();

  @override
  String newId() => const Uuid().v4();
}
