
import 'package:quran/models/quran/ayah.dart';
import 'package:quran/models/quran/ayah_line.dart';
import 'package:quran/models/quran/basmallah_line.dart';
import 'package:quran/models/quran/page_line.dart';
import 'package:quran/models/quran/surah_name_line.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/repositories/quran/quran_data.dart';

abstract class QuranUtils {
  static (int, int) indexToSurahAyah(int index) {
    final surahLengths =
        QuranData.surahs.map((c) => c.numberOfAyahs).toList();

    int surah = 1;
    int ayah = index;

    while (ayah > surahLengths[surah - 1]) {
      ayah -= surahLengths[surah - 1];
      surah++;
    }

    return (surah, ayah);
  }

  static int surahAyahToIndex(int surah, int ayah) {
    final surahLengths =
        QuranData.surahs.map((c) => c.numberOfAyahs).toList();

    int index = 0;
    for (int i = 1; i < surah; i++) {
      index += surahLengths[i - 1];
    }

    index += ayah;

    return index;
  }

  /// returns surahs of the first ayah in the page
  static int firstAyahInPage(int page) {
    final surahAyah = QuranData.pageSurahAyah[page - 1];
    return surahAyahToIndex(surahAyah[0], surahAyah[1] - 1);
  }
}

sealed class PageElement {}

class PageSurahName extends PageElement {
  final SurahNameLine line;
  PageSurahName(this.line);
}

class PageBasmallah extends PageElement {
  final BasmallahLine line;
  PageBasmallah(this.line);
}

class PageAyah extends PageElement {
  final Ayah ayah;
  PageAyah(this.ayah);
}
