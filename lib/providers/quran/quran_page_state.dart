import 'package:flutter/material.dart';
import 'package:quran/models/quran/ayah_model.dart';
import 'package:quran/models/quran/page_data.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/highlighter/highlighter_state.dart';

class WordClickContext {
  final Word word;
  final int page;
  final bool isCtrlPressed;
  final bool isRightClick;
  final bool isAltPressed;

  WordClickContext({
    required this.word,
    required this.page,
    this.isCtrlPressed = false,
    this.isRightClick = false,
    this.isAltPressed = false,
  });
}

final focusHighlight = Highlight(
  label: "focus",
  color: Colors.grey.withValues(alpha: 0.3),
  zIndex: 0,
  isFullHeight: true,
);

final ayahHighlight = Highlight(
  label: "ayah",
  color: Colors.yellow.withValues(alpha: 0.3),
  zIndex: 1,
);

final partialHighlight = Highlight(
  label: "partial",
  color: Colors.green.withValues(alpha: 0.3),
  zIndex: 5,
);

final wordHighlight = Highlight(
  label: "word",
  color: Colors.orange.withValues(alpha: 0.3),
  zIndex: 2,
);

enum HighlightAction {
  highlightWord, // ctrl + left click + !isAyahNrSymbol
  highlightAyah, // ctrl + left click + isAyahNrSymbol
  selectAyah, // ctrl + left click
  removeWordHighlight, // ctrl + right click !isAyahNrSymbol
  removeAyahHighlight, // ctrl + right click + isAyahNrSymbol
}

class QuranPageState {
  final Map<int, QuranPageData> pages;

  QuranPageState({required this.pages});

  factory QuranPageState.initial() {
    return QuranPageState(pages: {});
  }

  QuranPageState copyWith({Map<int, QuranPageData>? pages}) {
    return QuranPageState(pages: pages ?? this.pages);
  }

  QuranPageData? getPageData(int pageNumber) {
    final pageData = pages[pageNumber];
    return (pageData != null && !pageData.isEmpty) ? pageData : null;
  }

  List<Word> getWordsForAyah(int pageNumber, int surah, int ayah) {
    final data = getPageData(pageNumber);
    return data?.words.where((word) => word.surah == surah && word.ayah == ayah).toList() ?? [];
  }

  Ayah getAyahForWord(int pageNumber, Word word) {
    final ayahWords = getWordsForAyah(pageNumber, word.surah, word.ayah);
    final ayahText = ayahWords.map((w) => w.text).join(" ");
    return Ayah(page: pageNumber, surah: word.surah, ayah: word.ayah, text: ayahText);
  }
}
