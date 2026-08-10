int compareNaturalPaths(String left, String right) {
  final folded = _compareNatural(left.toLowerCase(), right.toLowerCase());
  return folded != 0 ? folded : _compareNatural(left, right);
}

int _compareNatural(String left, String right) {
  var leftIndex = 0;
  var rightIndex = 0;
  while (leftIndex < left.length && rightIndex < right.length) {
    final leftDigit = _isDigit(left.codeUnitAt(leftIndex));
    final rightDigit = _isDigit(right.codeUnitAt(rightIndex));
    if (leftDigit && rightDigit) {
      final leftStart = leftIndex;
      final rightStart = rightIndex;
      while (leftIndex < left.length && _isDigit(left.codeUnitAt(leftIndex))) {
        leftIndex++;
      }
      while (rightIndex < right.length &&
          _isDigit(right.codeUnitAt(rightIndex))) {
        rightIndex++;
      }
      final leftDigits = left.substring(leftStart, leftIndex);
      final rightDigits = right.substring(rightStart, rightIndex);
      final leftTrimmed = leftDigits.replaceFirst(RegExp(r'^0+'), '');
      final rightTrimmed = rightDigits.replaceFirst(RegExp(r'^0+'), '');
      final leftNumber = leftTrimmed.isEmpty ? '0' : leftTrimmed;
      final rightNumber = rightTrimmed.isEmpty ? '0' : rightTrimmed;
      if (leftNumber.length != rightNumber.length) {
        return leftNumber.length.compareTo(rightNumber.length);
      }
      final numberResult = leftNumber.compareTo(rightNumber);
      if (numberResult != 0) return numberResult;
      if (leftDigits.length != rightDigits.length) {
        return leftDigits.length.compareTo(rightDigits.length);
      }
      continue;
    }
    final result = left
        .codeUnitAt(leftIndex)
        .compareTo(right.codeUnitAt(rightIndex));
    if (result != 0) return result;
    leftIndex++;
    rightIndex++;
  }
  return (left.length - leftIndex).compareTo(right.length - rightIndex);
}

bool _isDigit(int value) => value >= 0x30 && value <= 0x39;
