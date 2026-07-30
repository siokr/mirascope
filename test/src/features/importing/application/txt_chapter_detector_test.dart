import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/features/importing/application/txt_chapter_detector.dart';
import 'package:mirascope/src/features/importing/domain/decoded_txt.dart';
import 'package:mirascope/src/features/importing/domain/detected_chapter.dart';
import 'package:mirascope/src/features/importing/domain/txt_encoding.dart';

void main() {
  const detector = TxtChapterDetector();

  group('heading samples', () {
    final samples = <(String, ChapterHeadingKind)>[
      ('第1章 标题', ChapterHeadingKind.chineseOrdinal),
      ('第一章 标题', ChapterHeadingKind.chineseOrdinal),
      ('第 12 章 标题', ChapterHeadingKind.chineseOrdinal),
      ('第十二回 标题', ChapterHeadingKind.chineseOrdinal),
      ('卷一 标题', ChapterHeadingKind.chineseVolume),
      ('第一卷 标题', ChapterHeadingKind.chineseOrdinal),
      ('第一话 标题', ChapterHeadingKind.chineseOrdinal),
      ('最终话 标题', ChapterHeadingKind.chineseOrdinal),
      ('闲话 标题', ChapterHeadingKind.chineseOrdinal),
      ('尾声', ChapterHeadingKind.chineseOrdinal),
      ('后记', ChapterHeadingKind.chineseOrdinal),
      ('Chapter 1 Title', ChapterHeadingKind.englishChapter),
      ('CHAPTER 24 A Title', ChapterHeadingKind.englishChapter),
    ];

    for (final sample in samples) {
      test('recognizes ${sample.$1}', () {
        final chapters = detector.detect(_decoded('${sample.$1}\n正文'));

        expect(chapters, hasLength(1));
        expect(chapters.single.title, sample.$1);
        expect(chapters.single.headingKind, sample.$2);
        expect(chapters.single.headingStartOffset, 0);
      });
    }
  });

  test('normalizes decorated light-novel headings', () {
    const text =
        '作品信息\n'
        '▶︎▶︎【【第一话】 掷骰子问题（Day176）】\n'
        '甲\n'
        '▶︎▶︎【【第二话】 Abstract•Queen的败北（Day58）】\n'
        '乙\n'
        '▶︎▶︎【【闲话】 Rental•Instruction（Day94）】\n'
        '丙';

    final chapters = detector.detect(_decoded(text));

    expect(chapters.map((chapter) => chapter.title), [
      '正文',
      '第一话 掷骰子问题（Day176）',
      '第二话 Abstract•Queen的败北（Day58）',
      '闲话 Rental•Instruction（Day94）',
    ]);
    expect(chapters[1].headingStartOffset, '作品信息\n'.length);
  });

  test('requires the complete line to be a heading', () {
    const text = '他说第一章已经结束，但故事仍在继续。\n下一段正文。';

    final chapters = detector.detect(_decoded(text));

    expect(chapters, hasLength(1));
    expect(chapters.single.headingKind, ChapterHeadingKind.fallback);
    expect(chapters.single.endOffset, text.length);
  });

  test('rejects overlong and ambiguous heading-like lines', () {
    final longTitle = '第1章 ${'很长' * 40}';
    final text = '$longTitle\n正文\nChapter One\n正文';

    final chapters = detector.detect(_decoded(text));

    expect(chapters, hasLength(1));
    expect(chapters.single.headingKind, ChapterHeadingKind.fallback);
  });

  test('preserves preface and stable UTF-16 source offsets', () {
    const text = '序言😀\n\n第一章 开始\n甲\nChapter 2 Next\n乙';

    final chapters = detector.detect(_decoded(text));

    expect(chapters.map((chapter) => chapter.title), [
      '正文',
      '第一章 开始',
      'Chapter 2 Next',
    ]);
    expect(
      chapters.map(
        (chapter) => text.substring(chapter.startOffset, chapter.endOffset),
      ),
      ['序言😀\n\n', '第一章 开始\n甲\n', 'Chapter 2 Next\n乙'],
    );
    expect(chapters[1].headingStartOffset, '序言😀\n\n'.length);
    expect(
      text.substring(chapters[1].bodyStartOffset, chapters[1].endOffset),
      '甲\n',
    );
  });

  test('suppresses empty consecutive headings without losing text', () {
    const text = '第一章 空\n\n第二章 有内容\n正文';

    final chapters = detector.detect(_decoded(text));

    expect(chapters, hasLength(1));
    expect(chapters.single.title, '第二章 有内容');
    expect(chapters.single.startOffset, 0);
    expect(text.substring(chapters.single.startOffset), text);
  });

  test('keeps ordering and covers the complete source contiguously', () {
    const text = '第1章 一\n甲\n第2章 二\n乙\n第3章 三\n丙';

    final chapters = detector.detect(_decoded(text));

    expect(chapters.map((chapter) => chapter.title), [
      '第1章 一',
      '第2章 二',
      '第3章 三',
    ]);
    expect(chapters.first.startOffset, 0);
    expect(chapters.last.endOffset, text.length);
    for (var index = 1; index < chapters.length; index++) {
      expect(chapters[index - 1].endOffset, chapters[index].startOffset);
    }
  });

  test('falls back to one body chapter when no heading is reliable', () {
    const text = '只是正文。\n\n仍然是正文。';

    final chapters = detector.detect(_decoded(text));

    expect(chapters, hasLength(1));
    expect(chapters.single.title, '正文');
    expect(chapters.single.headingKind, ChapterHeadingKind.fallback);
    expect(chapters.single.headingStartOffset, isNull);
    expect(chapters.single.startOffset, 0);
    expect(chapters.single.bodyStartOffset, 0);
    expect(chapters.single.endOffset, text.length);
  });

  test('empty input has no readable chapter', () {
    expect(detector.detect(_decoded('')), isEmpty);
  });
}

DecodedTxt _decoded(String text) {
  return DecodedTxt(
    encoding: TxtEncoding.utf8,
    text: text,
    preview: text,
    userSelectedEncoding: false,
  );
}
