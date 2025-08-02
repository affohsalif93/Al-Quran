import 'package:quran/models/quran/ayah_model.dart';
import 'package:quran/models/quran/page_line.dart';
import 'package:quran/models/quran/word.dart';

import 'ayah_line.dart';

class QuranPageData {
  final int pageNumber;
  final Map<int, PageLine> lines;
  final List<Word> words;
  final Map<(int surah, int ayah), List<Word>> ayahToWordsMap;

  QuranPageData({required this.pageNumber, required this.lines, required this.words, required this.ayahToWordsMap});

  static empty() {
    return QuranPageData(pageNumber: 0, lines: {}, words: [], ayahToWordsMap: {});
  }

  get firstAyahOfPage {
    final firstAyahLine =
        lines.values.firstWhere((line) => line.lineType == LineType.ayah) as AyahLine;

    final firstWord = words.firstWhere((word) => word.id == firstAyahLine.words.first.id);

    final ayahText = words
        .where((word) => word.surah == firstWord.surah && word.ayah == firstWord.ayah)
        .map((word) => word.text)
        .join(" ");

    return Ayah(
      page: firstAyahLine.pageNumber,
      surah: firstWord.surah,
      ayah: firstWord.ayah,
      text: ayahText,
    );
  }

  get isEmpty {
    return lines.isEmpty && words.isEmpty && ayahToWordsMap.isEmpty;
  }
}
