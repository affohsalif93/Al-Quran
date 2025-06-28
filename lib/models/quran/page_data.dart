import 'package:quran/models/quran/word.dart';

import 'page_line.dart';

class QuranPageData {
  final Map<int, PageLine> lines;
  final List<Word> words;
  final Map<(int surah, int ayah), List<Word>> ayahMap;

  QuranPageData({
    required this.lines,
    required this.words,
    required this.ayahMap,
  });
}
