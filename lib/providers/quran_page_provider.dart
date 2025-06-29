import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/ayah_line.dart';
import 'package:quran/models/quran/page_data.dart';
import 'package:quran/models/quran/page_line.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/highlighter/highlighter_provider.dart';
import 'package:quran/providers/highlighter/highlighter_state.dart';
import 'package:quran/providers/home/home_controller.dart';
import 'package:quran/providers/home/home_state.dart';
import 'package:quran/repositories/quran/quran_repository.dart';

final quranPageControllerProvider = NotifierProvider<QuranPageController, QuranPageState>(
  () => QuranPageController(),
);

class WordClickContext {
  final Word word;
  final int page;
  final bool isCtrlPressed;
  final bool isRightClick;

  WordClickContext({
    required this.word,
    required this.page,
    this.isCtrlPressed = false,
    this.isRightClick = false,
  });
}

class QuranPageState {
  final QuranPageData data;
  final int currentPage;

  QuranPageState({required this.data, this.currentPage = 1});

  QuranPageState copyWith({QuranPageData? data, int? currentPage}) {
    return QuranPageState(data: data ?? this.data, currentPage: currentPage ?? this.currentPage);
  }

  List<Word> getWordsForAyah(int surah, int ayah) {
    return data.words.where((word) => word.surah == surah && word.ayah == ayah).toList();
  }
}

final focusHighlighter = LabeledHighlight(
  label: "focus",
  color: Colors.grey.withOpacity(0.3),
  highlights: {},
);

final genericHighlighter = LabeledHighlight(
  label: "generic",
  color: Colors.yellow.withOpacity(0.3),
  highlights: {},
);

class QuranPageController extends Notifier<QuranPageState> {
  @override
  QuranPageState build() {
    return QuranPageState(data: QuranPageData.empty(), currentPage: 1);
  }

  Future<void> loadPage(int pageNumber, QuranRepository repo) async {
    final data = await repo.getPageData(pageNumber);
    state = QuranPageState(data: data, currentPage: pageNumber);
    // Auto-focus on the first Ayah of the page

    final homeState = ref.read(homeControllerProvider);

    if (!homeState.isMushafTab) {
      autoFocusOnFirstAyahOfPage(data);
    }
  }

  (int, int, int) getFirstAyahOfPage(QuranPageData data) {
    final firstAyahLine =
        data.lines.values.firstWhere((line) => line.lineType == LineType.ayah) as AyahLine;

    final firstWord = data.words.firstWhere((word) => word.id == firstAyahLine.words.first.id);

    return (firstAyahLine.pageNumber, firstWord.surah, firstWord.ayah);
  }

  void autoFocusOnFirstAyahOfPage(QuranPageData data) {
    final f = getFirstAyahOfPage(data);
    focusOnAyah(f.$1, f.$2, f.$3);
  }

  void focusOnAyah(int pageNumber, int surah, int ayah) {
    final highlighter = ref.read(highlightControllerProvider.notifier);
    final ayahWords = state.getWordsForAyah(surah, ayah) ?? [];

    highlighter.clearAllForLabel(focusHighlighter.label);

    final ayahWordLocations = ayahWords.map((w) => (pageNumber, w.location)).toList();

    highlighter.highlightWords(
      label: focusHighlighter.label,
      color: focusHighlighter.color,
      targets: ayahWordLocations,
    );
  }

  void highlightWords(int pageNumber, List<Word> words) {
    final highlighter = ref.read(highlightControllerProvider.notifier);
    final wordLocations = words.map((w) => (pageNumber, w.location)).toList();

    highlighter.highlightWords(
      label: genericHighlighter.label,
      color: genericHighlighter.color,
      targets: wordLocations,
    );
  }

  void handleWordClick(WordClickContext ctx, WidgetRef ref) {
    final highlighterState = ref.read(highlightControllerProvider);

    final isWordHighlight =
        highlighterState.mode == HighlightMode.highlight &&
        ctx.isCtrlPressed &&
        !ctx.word.isAyahNrSymbol;
    final isFocusHighlight = highlighterState.mode == HighlightMode.focus;

    if (isWordHighlight) {
      logger.fine("Highlighting word ${ctx.word.surah}:${ctx.word.ayah} on page ${ctx.page}");
      highlightWords(ctx.page, [ctx.word]);
    } else if (isFocusHighlight) {
      logger.fine("Highlighting Ayah ${ctx.word.surah}:${ctx.word.ayah} on page ${ctx.page}");
      focusOnAyah(ctx.page, ctx.word.surah, ctx.word.ayah);
    }
  }
}
