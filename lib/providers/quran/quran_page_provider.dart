import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/ayah_model.dart';
import 'package:quran/models/quran/ayah_line.dart';
import 'package:quran/models/quran/page_data.dart';
import 'package:quran/models/quran/page_line.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/global/global_provider.dart';
import 'package:quran/providers/global/global_state.dart';
import 'package:quran/providers/highlighter/highlighter_provider.dart';
import 'package:quran/providers/highlighter/highlighter_state.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/repositories/quran/quran_repository.dart';

// final quranPageControllerProvider = NotifierProvider.family
//     .autoDispose<QuranPageController, QuranPageState, int>(() => QuranPageController());
//
final quranDualPageProvider = NotifierProvider<QuranDualPageController, QuranDualPageState>(
  () => QuranDualPageController(),
);

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

class QuranDualPageState {
  final Map<int, QuranPageData> pages;

  QuranDualPageState({required this.pages});

  factory QuranDualPageState.initial() {
    return QuranDualPageState(pages: {});
  }

  QuranDualPageState copyWith({Map<int, QuranPageData>? pages}) {
    return QuranDualPageState(pages: pages ?? this.pages);
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

class QuranDualPageController extends Notifier<QuranDualPageState> {
  @override
  QuranDualPageState build() {
    ref.listen(globalControllerProvider.select((state) => state.currentPage), (previous, next) {
      if (previous != next) {
        focusOnFirstAyahOfPage(next);
      }
    });

    return QuranDualPageState.initial();
  }

  Future<void> loadPage(int pageNumber) async {
    // Check if page already exists and is not empty
    if (state.getPageData(pageNumber) != null) return;

    try {
      final repo = ref.read(quranRepositoryProvider);
      final pageData = await repo.getPageData(pageNumber);

      // Update pages
      final newPages = Map<int, QuranPageData>.from(state.pages)..[pageNumber] = pageData;
      state = state.copyWith(pages: newPages);

      // focusOnFirstAyahOfPage(pageNumber);
    } catch (e, st) {
      logger.error("Failed to load page $pageNumber: $e");
      logger.error("Stack trace: $st");
    }
  }

  void focusOnFirstAyahOfPage(int pageNumber) {
    final globalState = ref.read(globalControllerProvider);
    final globalController = ref.read(globalControllerProvider.notifier);
    final data = state.getPageData(pageNumber);

    if (data == null) return;

    if ((globalState.isBookView && (pageNumber % 2 == 1)) ||
        (!globalState.isBookView && pageNumber == globalState.currentPage)) {
      final ayah = data.firstAyahOfPage;
      globalController.setSelectedAyah(ayah);
      focusHighlightAyah(pageNumber, ayah);
    }
  }

  void focusHighlightAyah(int pageNumber, Ayah ayah) {
    final highlighter = ref.read(highlightControllerProvider.notifier);
    final ayahWords = state.getWordsForAyah(pageNumber, ayah.surah, ayah.ayah);

    highlighter.clearAllForLabel(focusHighlight.label);
    final ayahWordLocations = ayahWords.map((w) => (pageNumber, w.location)).toList();
    highlighter.highlightWords(highlight: focusHighlight, targets: ayahWordLocations);
  }

  void handleWordClick(WordClickContext ctx, WidgetRef ref) {
    final highlighterState = ref.read(highlightControllerProvider);
    final highlighterController = ref.read(highlightControllerProvider.notifier);
    final action = getHighlightAction(ctx);

    if (action case HighlightAction.highlightWord) {
      highlighterController.highlightWords(
        highlight: wordHighlight,
        targets: [(ctx.page, ctx.word.location)],
      );
    } else if (action case HighlightAction.highlightAyah) {
      final words = state.getWordsForAyah(ctx.page, ctx.word.surah, ctx.word.ayah);
      final wordLocations = words.map((w) => (ctx.page, w.location)).toList();
      highlighterController.highlightWords(highlight: ayahHighlight, targets: wordLocations);
    } else if (action case HighlightAction.selectAyah) {
      final ayah = state.getAyahForWord(ctx.page, ctx.word);
      focusHighlightAyah(ctx.page, ayah);
    } else if (action case HighlightAction.removeWordHighlight) {
      highlighterController.removeWordsHighlight(
        highlight: wordHighlight,
        targets: [(ctx.page, ctx.word.location)],
      );
    } else if (action case HighlightAction.removeAyahHighlight) {
      highlighterController.removeWordsHighlight(
        highlight: ayahHighlight,
        targets:
            state
                .getWordsForAyah(ctx.page, ctx.word.surah, ctx.word.ayah)
                .map((w) => (ctx.page, w.location))
                .toList(),
      );
    }
  }

  HighlightAction? getHighlightAction(WordClickContext ctx) {
    final isLeftClick = !ctx.isRightClick;
    final isRightClick = ctx.isRightClick;
    final isCtrlPressed = ctx.isCtrlPressed;
    final isAltPressed = ctx.isAltPressed;
    final isWord = !ctx.word.isAyahNrSymbol;
    final isAyah = ctx.word.isAyahNrSymbol;

    if (isCtrlPressed && isLeftClick && isWord) {
      return HighlightAction.highlightWord;
    } else if (isCtrlPressed && isLeftClick && isAyah) {
      return HighlightAction.highlightAyah;
    } else if (isLeftClick && isAyah) {
      return HighlightAction.selectAyah;
    } else if (isCtrlPressed && isRightClick && isWord) {
      return HighlightAction.removeWordHighlight;
    } else if (isCtrlPressed && isRightClick && isAyah) {
      return HighlightAction.removeAyahHighlight;
    }
    return null;
  }
}
