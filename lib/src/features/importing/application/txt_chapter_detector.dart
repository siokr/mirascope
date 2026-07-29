import '../domain/detected_chapter.dart';
import '../domain/decoded_txt.dart';

final class TxtChapterDetector {
  const TxtChapterDetector({this.maximumHeadingCodePoints = 80});

  final int maximumHeadingCodePoints;

  static final RegExp _chineseOrdinal = RegExp(
    r'^第\s*[0-9零〇一二三四五六七八九十百千万两]+\s*[章节回卷](?:\s+.+)?$',
  );
  static final RegExp _chineseVolume = RegExp(
    r'^卷\s*[0-9零〇一二三四五六七八九十百千万两]+(?:\s+.+)?$',
  );
  static final RegExp _englishChapter = RegExp(
    r'^chapter\s+[0-9]+(?:\s+.+)?$',
    caseSensitive: false,
  );

  List<DetectedChapter> detect(DecodedTxt decodedTxt) {
    final text = decodedTxt.text;
    if (text.isEmpty) {
      return const <DetectedChapter>[];
    }

    final candidates = _findCandidates(text);
    if (candidates.isEmpty) {
      return <DetectedChapter>[_fallback(text.length)];
    }

    final retained = <_HeadingCandidate>[];
    for (var index = 0; index < candidates.length; index++) {
      final candidate = candidates[index];
      final nextStart = index + 1 < candidates.length
          ? candidates[index + 1].lineStart
          : text.length;
      if (_containsReadableBody(text, candidate.bodyStart, nextStart)) {
        retained.add(candidate);
      }
    }

    if (retained.isEmpty) {
      return <DetectedChapter>[_fallback(text.length)];
    }

    final chapters = <DetectedChapter>[];
    final first = retained.first;
    if (first.lineStart == candidates.first.lineStart &&
        _containsReadableBody(text, 0, first.lineStart)) {
      chapters.add(
        DetectedChapter(
          title: '正文',
          headingKind: ChapterHeadingKind.fallback,
          startOffset: 0,
          bodyStartOffset: 0,
          endOffset: first.lineStart,
        ),
      );
    }

    for (var index = 0; index < retained.length; index++) {
      final heading = retained[index];
      final start = index == 0 && chapters.isEmpty ? 0 : heading.lineStart;
      final end = index + 1 < retained.length
          ? retained[index + 1].lineStart
          : text.length;
      chapters.add(
        DetectedChapter(
          title: heading.title,
          headingKind: heading.kind,
          startOffset: start,
          headingStartOffset: heading.lineStart,
          bodyStartOffset: heading.bodyStart,
          endOffset: end,
        ),
      );
    }

    return List<DetectedChapter>.unmodifiable(chapters);
  }

  List<_HeadingCandidate> _findCandidates(String text) {
    final candidates = <_HeadingCandidate>[];
    var lineStart = 0;

    while (lineStart < text.length) {
      final newline = text.indexOf('\n', lineStart);
      final lineEnd = newline == -1 ? text.length : newline;
      final line = text.substring(lineStart, lineEnd).trim();
      final kind = _classify(line);
      if (kind != null) {
        candidates.add(
          _HeadingCandidate(
            title: line,
            kind: kind,
            lineStart: lineStart,
            bodyStart: newline == -1 ? text.length : newline + 1,
          ),
        );
      }
      if (newline == -1) {
        break;
      }
      lineStart = newline + 1;
    }

    return candidates;
  }

  ChapterHeadingKind? _classify(String line) {
    if (line.isEmpty ||
        line.runes.length > maximumHeadingCodePoints ||
        maximumHeadingCodePoints < 1) {
      return null;
    }
    if (_chineseOrdinal.hasMatch(line)) {
      return ChapterHeadingKind.chineseOrdinal;
    }
    if (_chineseVolume.hasMatch(line)) {
      return ChapterHeadingKind.chineseVolume;
    }
    if (_englishChapter.hasMatch(line)) {
      return ChapterHeadingKind.englishChapter;
    }
    return null;
  }

  bool _containsReadableBody(String text, int start, int end) {
    for (final codePoint in text.substring(start, end).runes) {
      if (!_isWhitespace(codePoint)) {
        return true;
      }
    }
    return false;
  }

  bool _isWhitespace(int codePoint) {
    return codePoint == 0x09 ||
        codePoint == 0x0a ||
        codePoint == 0x0b ||
        codePoint == 0x0c ||
        codePoint == 0x0d ||
        codePoint == 0x20 ||
        codePoint == 0x85 ||
        codePoint == 0xa0 ||
        codePoint == 0x1680 ||
        (codePoint >= 0x2000 && codePoint <= 0x200a) ||
        codePoint == 0x2028 ||
        codePoint == 0x2029 ||
        codePoint == 0x202f ||
        codePoint == 0x205f ||
        codePoint == 0x3000 ||
        codePoint == 0xfeff;
  }

  DetectedChapter _fallback(int textLength) {
    return DetectedChapter(
      title: '正文',
      headingKind: ChapterHeadingKind.fallback,
      startOffset: 0,
      bodyStartOffset: 0,
      endOffset: textLength,
    );
  }
}

final class _HeadingCandidate {
  const _HeadingCandidate({
    required this.title,
    required this.kind,
    required this.lineStart,
    required this.bodyStart,
  });

  final String title;
  final ChapterHeadingKind kind;
  final int lineStart;
  final int bodyStart;
}
