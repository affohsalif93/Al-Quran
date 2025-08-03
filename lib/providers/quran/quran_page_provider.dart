import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/ayah.dart';
import 'package:quran/models/quran/page_data.dart';
import 'package:quran/providers/highlighter/highlighter_provider.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/providers/quran/quran_page_state.dart';
import 'package:quran/repositories/quran/quran_repository.dart';


final quranDualPageProvider = NotifierProvider<QuranPageController, QuranPageState>(
  () => QuranPageController(),
);


class QuranPageController extends Notifier<QuranPageState> {
  @override
  QuranPageState build() {
    ref.listen(globalControllerProvider.select((state) => state.currentPage), (previous, next) {
      if (previous != next) {
        focusOnFirstAyahOfPage(next);
      }
    });

    return QuranPageState.initial();
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

    ref.read(globalControllerProvider.notifier).setSelectedAyah(ayah);
  }

  void handleWordClick(WordClickContext ctx, WidgetRef ref) {
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
      final ayah = state.getAyah(ctx.page, ctx.word.surah, ctx.word.ayah);
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
