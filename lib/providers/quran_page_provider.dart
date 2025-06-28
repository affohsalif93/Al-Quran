import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/models/quran/ayah_line.dart';
import 'package:quran/models/quran/page_data.dart';
import 'package:quran/models/quran/page_line.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/highlighter/highlighter_provider.dart';
import 'package:quran/providers/word_click_provider.dart';
import 'package:quran/repositories/quran/quran_repository.dart';

final quranPageControllerProvider =
NotifierProvider<QuranPageController, QuranPageState?>(() => QuranPageController());

class QuranPageState {
  final QuranPageData data;

  QuranPageState({
    required this.data,
  });

  QuranPageState copyWith({
    QuranPageData? data,
  }) {
    return QuranPageState(
      data: data ?? this.data,
    );
  }

  List<Word> getWordsForAyah(int surah, int ayah) {
    return data.words.where((word) => word.surah == surah && word.ayah == ayah).toList();
  }
}

class QuranPageController extends Notifier<QuranPageState?> {
  int _currentPage = 1;

  @override
  QuranPageState? build() => null;

  Future<void> loadPage(int pageNumber, QuranRepository repo) async {
    final lines = await repo.getPageData(pageNumber);
  }

  void handleWordClick(WordClickContext ctx, WidgetRef ref) {
    final highlighter = ref.read(highlightControllerProvider.notifier);
    final verseWords = state?.getWordsForAyah(ctx.word.surah, ctx.word.ayah) ?? [];

    if (ctx.ctrlPressed) {
      highlighter.toggleWordsHighlight(_currentPage, [ctx.word.location]);
    } else {
      final locations = verseWords.map((w) => w.location).toList();
      highlighter.toggleWordsHighlight(_currentPage, locations);
    }
  }


  // if (ctx.isRightClick) {
  // logger.info("Right click detected");
  // } else {
  // if (word.isAyahNrSymbol) {
  // highlighter.highlightWords(pageNumber, ayahWordLocations);
  // } else {
  // if (isCtrlPressed) {
  // highlighter.highlightWords(pageNumber, [word.location]);
  // } else {
  // logger.fine("Highlighting words for verse ${word.surah}:${word.ayah} on page $pageNumber");
  // highlighter.highlightWords(pageNumber, ayahWordLocations);
  // }
  // }
  // }
}
