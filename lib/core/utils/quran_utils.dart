
import 'package:quran/repositories/quran/quran_data.dart';

abstract class QuranUtils {
  static (int, int) indexToSurahVerse(int index) {
    final surahLengths =
        QuranData.surahs.map((c) => c.numberOfAyahs).toList();

    int surah = 1;
    int verse = index;

    while (verse > surahLengths[surah - 1]) {
      verse -= surahLengths[surah - 1];
      surah++;
    }

    return (surah, verse);
  }

  static int surahVerseToIndex(int surah, int verse) {
    final surahLengths =
        QuranData.surahs.map((c) => c.numberOfAyahs).toList();

    int index = 0;
    for (int i = 1; i < surah; i++) {
      index += surahLengths[i - 1];
    }

    index += verse;

    return index;
  }

  /// returns surahs of the first verse in the page
  static int firstVerseInPage(int page) {
    final surahVerse = QuranData.pageSurahVerse[page - 1];
    return surahVerseToIndex(surahVerse[0], surahVerse[1] - 1);
  }
}

