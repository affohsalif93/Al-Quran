
import 'package:quran/models/ayah_model.dart';
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


List<PageElement> extractPageElementsFromLines(List<PageLine> lines) {
  final List<PageElement> result = [];

  // To accumulate ayah lines grouped by (surah, ayah)
  final Map<(int surah, int ayah), List<AyahLineSpan>> ayahMap = {};
  final Map<(int surah, int ayah), int> firstLineAppearance = {};

  for (final line in lines) {
    if (line is SurahNameLine) {
      result.add(PageSurahName(line));
    } else if (line is BasmallahLine) {
      result.add(PageBasmallah(line));
    } else if (line is AyahLine) {
      final grouped = <(int surah, int ayah), List<Word>>{};

      for (final word in line.words) {
        final key = (word.surah, word.ayah);
        grouped.putIfAbsent(key, () => []).add(word);
      }

      for (final entry in grouped.entries) {
        final key = entry.key;
        final span = AyahLineSpan(lineNumber: line.lineNumber, words: entry.value);

        ayahMap.putIfAbsent(key, () => []).add(span);

        // Record line number where this ayah first appeared for ordering later
        firstLineAppearance.putIfAbsent(key, () => line.lineNumber);
      }
    }
  }

  // Sort ayahs by first line appearance
  final sortedAyahs = ayahMap.entries.toList()
    ..sort((a, b) {
      final la = firstLineAppearance[a.key]!;
      final lb = firstLineAppearance[b.key]!;
      return la.compareTo(lb);
    });

  for (final entry in sortedAyahs) {
    final (surah, ayah) = entry.key;
    result.add(PageAyah(
      Ayah(surah: surah, ayah: ayah, spans: entry.value, text: ""),
    ));
  }

  return result;
}