import 'package:quran/models/quran/page_line.dart';
import 'package:quran/models/quran/word.dart';

class QuranPageData {
  final Map<int, PageLine> lines;
  final List<Word> words;
  final Map<(int surah, int ayah), List<Word>> ayahToWordsMap;

  QuranPageData({
    required this.lines,
    required this.words,
    required this.ayahToWordsMap,
  });

  static empty() {
    return QuranPageData(
      lines: {},
      words: [],
      ayahToWordsMap: {},
    );
  }
}
