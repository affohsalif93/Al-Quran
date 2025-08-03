import 'package:quran/models/quran/ayah.dart';
import 'package:quran/models/quran/page_line.dart';
import 'package:quran/models/quran/word.dart';

import 'ayah_line.dart';

class QuranPageData {
  final int pageNumber;
  final Map<int, PageLine> lines;
  final List<Word> words;
  final Map<(int surah, int ayah), List<Word>> ayahToWordsMap;
  final List<Ayah> ayahs;

  QuranPageData({
    required this.pageNumber,
    required this.lines,
    required this.words,
    required this.ayahToWordsMap,
    required this.ayahs,
  });

  static empty() {
    return QuranPageData(pageNumber: 0, lines: {}, words: [], ayahToWordsMap: {}, ayahs: []);
  }

  get firstAyahOfPage {
    return ayahs.first;
  }

  Ayah getAyah(int surah, int ayah) {
    return ayahs.firstWhere((ayah) => ayah.surah == surah && ayah.ayah == ayah);
  }

  get isEmpty {
    return lines.isEmpty && words.isEmpty && ayahToWordsMap.isEmpty;
  }
}
