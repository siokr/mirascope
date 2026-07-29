enum TxtEncoding {
  utf8('utf8'),
  utf16le('utf16le'),
  utf16be('utf16be'),
  gb18030('gb18030');

  const TxtEncoding(this.storageValue);

  final String storageValue;

  static TxtEncoding fromStorageValue(String value) {
    for (final encoding in TxtEncoding.values) {
      if (encoding.storageValue == value) {
        return encoding;
      }
    }
    throw ArgumentError.value(value, 'value', 'Unknown TXT encoding');
  }
}

abstract interface class Gb18030Decoder {
  Future<String> decode(List<int> bytes);
}
