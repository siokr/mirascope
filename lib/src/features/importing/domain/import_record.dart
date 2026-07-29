import 'txt_encoding.dart';

enum ImportSourceKind {
  txtFile('txtFile'),
  epubFile('epubFile'),
  mangaDirectory('mangaDirectory'),
  mangaArchive('mangaArchive');

  const ImportSourceKind(this.storageValue);

  final String storageValue;

  static ImportSourceKind fromStorageValue(String value) {
    for (final sourceKind in ImportSourceKind.values) {
      if (sourceKind.storageValue == value) {
        return sourceKind;
      }
    }
    throw ArgumentError.value(value, 'value', 'Unknown import source kind');
  }
}

enum ImportStatus {
  pending('pending'),
  completed('completed'),
  failed('failed'),
  missing('missing');

  const ImportStatus(this.storageValue);

  final String storageValue;

  static ImportStatus fromStorageValue(String value) {
    for (final status in ImportStatus.values) {
      if (status.storageValue == value) {
        return status;
      }
    }
    throw ArgumentError.value(value, 'value', 'Unknown import status');
  }
}

final class ImportRecord {
  const ImportRecord({
    required this.id,
    this.mediaItemId,
    required this.sourcePath,
    required this.sourceKind,
    required this.fileSize,
    this.modifiedAt,
    required this.fingerprint,
    this.textEncoding,
    required this.status,
    this.errorCode,
    required this.createdAt,
  });

  final String id;
  final String? mediaItemId;
  final String sourcePath;
  final ImportSourceKind sourceKind;
  final int fileSize;
  final DateTime? modifiedAt;
  final String fingerprint;
  final TxtEncoding? textEncoding;
  final ImportStatus status;
  final String? errorCode;
  final DateTime createdAt;
}
