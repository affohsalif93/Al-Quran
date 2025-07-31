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

final quranPageControllerProvider = NotifierProvider.family
    .autoDispose<QuranPageController, QuranPageState, int>(() => QuranPageController());

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

class QuranPageState {
  final QuranPageData data;
  final int currentPage;

  QuranPageState({required this.data, required this.currentPage});

  QuranPageState copyWith({QuranPageData? data, int? currentPage}) {
    return QuranPageState(data: data ?? this.data, currentPage: currentPage ?? this.currentPage);
  }

  List<Word> getWordsForAyah(int surah, int ayah) {
    return data.words.where((word) => word.surah == surah && word.ayah == ayah).toList();
  }
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

class QuranPageController extends AutoDisposeFamilyNotifier<QuranPageState, int> {
  late final int pageNumber;

  @override
  QuranPageState build(int pageNumber) {
    this.pageNumber = pageNumber;
    final initialState = QuranPageState(data: QuranPageData.empty(), currentPage: pageNumber);

    ref.listen<GlobalState>(globalControllerProvider, (prev, next) {
      final wasNull = prev?.selectedAyah == null;
      final isNowNonNull = next.selectedAyah != null;

      if (wasNull && isNowNonNull) {
        final shouldFocus = state.data.words.isNotEmpty;
        if (shouldFocus) {
          logger.fine("selectedAyah became non-null -> focus first ayah of page $pageNumber");
          autoFocusOnFirstAyahOfPage(state.data);
        } else {
          logger.warning("Page $pageNumber has no data yet, skipping focus");
        }
      }
    });

    return initialState;
  }

  Future<void> loadPage() async {
    final repo = ref.read(quranRepositoryProvider);
    final data = await repo.getPageData(pageNumber);

    state = QuranPageState(data: data, currentPage: pageNumber);
    autoFocusOnFirstAyahOfPage(data);
  }

  Ayah _getFirstAyahOfPage(QuranPageData data) {
    final firstAyahLine =
        data.lines.values.firstWhere((line) => line.lineType == LineType.ayah) as AyahLine;

    final firstWord = data.words.firstWhere((word) => word.id == firstAyahLine.words.first.id);

    final ayahText = data.words
        .where((word) {
          return word.surah == firstWord.surah && word.ayah == firstWord.ayah;
        })
        .toList()
        .join("");

    return Ayah(
      pageNumber: firstAyahLine.pageNumber,
      surah: firstWord.surah,
      ayah: firstWord.ayah,
      text: ayahText,
    );
  }

  void autoFocusOnFirstAyahOfPage(QuranPageData data) {
    final globalState = ref.read(globalControllerProvider);
    final globalController = ref.read(globalControllerProvider.notifier);

    if (globalState.selectedAyah == null) {
      logger.fine("No ayah selected");
      // return;
    }

    final ayah = _getFirstAyahOfPage(data);
    logger.fine("Auto-focusing on first ayah of page: ${ayah.pageNumber}");
    globalController.setSelectedAyah(ayah);
    focusOnAyah(ayah);
  }

  void focusOnAyah(Ayah ayah) {
    // final highlighter = ref.read(highlightControllerProvider.notifier);
    // final globalController = ref.read(globalControllerProvider.notifier);
    // final ayahWords = state.getWordsForAyah(ayah.surah, ayah.ayah);
    //
    // final focusedWords = highlighter.getWordsForLabel(focusHighlight.label);
    //
    // highlighter.clearAllForLabel(focusHighlight.label);
    //
    // final firstWordOfHighlight = (ayah.pageNumber, "${ayah.surah}:${ayah.ayah}:1");
    //
    // if (focusedWords.contains(firstWordOfHighlight)) {
    //   globalController.clearSelectedAyah();
    //   return;
    // }
    //
    // final ayahWordLocations = ayahWords.map((w) => (pageNumber, w.location)).toList();
    //
    // highlighter.highlightWords(highlight: focusHighlight, targets: ayahWordLocations);
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
      final words = state.getWordsForAyah(ctx.word.surah, ctx.word.ayah);
      final wordLocations = words.map((w) => (ctx.page, w.location)).toList();
      highlighterController.highlightWords(highlight: ayahHighlight, targets: wordLocations);
    } else if (action case HighlightAction.selectAyah) {
      focusOnAyah(Ayah(pageNumber: ctx.page, surah: ctx.word.surah, ayah: ctx.word.ayah, text: ""));
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
                .getWordsForAyah(ctx.word.surah, ctx.word.ayah)
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
