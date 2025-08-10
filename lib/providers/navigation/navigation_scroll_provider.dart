import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/constants.dart';
import 'package:quran/providers/global/global_provider.dart';
import 'package:quran/repositories/quran_data.dart';

enum NavigationType { surah, juz, hizb, rub }

final navigationScrollProvider = Provider.family<NavigationScrollHelper, NavigationType>((
  ref,
  type,
) {
  return NavigationScrollHelper(type, ref);
});

class NavigationScrollHelper {
  final NavigationType type;
  final Ref ref;

  NavigationScrollHelper(this.type, this.ref);

  void scrollToCurrentPage(ScrollController scrollController) {
    final currentPage = ref.read(currentPageProvider);
    final firstAyahOfPage = QuranData.pageAyahMap[currentPage]?.first;

    if (firstAyahOfPage == null) return;

    int? targetIndex;

    switch (type) {
      case NavigationType.surah:
        targetIndex = _getSurahIndex(firstAyahOfPage.surah);
        break;
      case NavigationType.juz:
        targetIndex = _getJuzIndex(firstAyahOfPage.juz);
        break;
      case NavigationType.hizb:
        targetIndex = _getHizbIndex(firstAyahOfPage.surah, firstAyahOfPage.ayah);
        break;
      case NavigationType.rub:
        targetIndex = _getRubIndex(firstAyahOfPage.rub);
        break;
    }

    if (targetIndex != null && targetIndex != -1 && scrollController.hasClients) {
      final itemHeight = Constants.navCardHeight;
      final targetOffset = targetIndex * itemHeight;

      scrollController.jumpTo(targetOffset);
    }
  }

  int? _getSurahIndex(int surahNumber) {
    return QuranData.surahs.indexWhere((s) => s.surahNumber == surahNumber);
  }

  int? _getJuzIndex(int juzNumber) {
    return QuranData.juzs.indexWhere((j) => j.juzNumber == juzNumber);
  }

  int? _getHizbIndex(int surah, int ayah) {
    final hizbNumber = _findHizbForAyah(surah, ayah);
    if (hizbNumber == null) return null;
    return QuranData.hizbs.indexWhere((h) => h.hizbNumber == hizbNumber);
  }

  int? _getRubIndex(int rubNumber) {
    return QuranData.rubs.indexWhere((r) => r.rubNumber == rubNumber);
  }

  int? _findHizbForAyah(int surah, int ayah) {
    // Find the hizb that starts at or before this ayah
    for (int i = QuranData.hizbs.length - 1; i >= 0; i--) {
      final hizb = QuranData.hizbs[i];
      if (hizb.firstSurah < surah || (hizb.firstSurah == surah && hizb.firstAyah <= ayah)) {
        return hizb.hizbNumber;
      }
    }
    return null;
  }
}
