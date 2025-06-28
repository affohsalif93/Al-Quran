import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/highlighter/highlighter_provider.dart';

final wordClickControllerProvider = NotifierProvider<WordClickController, void>(() => WordClickController());

enum WordClickMode { highlightVerse, highlightSingle, viewAyahTafsir }

class WordClickContext {
  final Word word;
  final int page;
  final bool ctrlPressed;
  final bool isRightClick;

  WordClickContext({
    required this.word,
    required this.page,
    this.ctrlPressed = false,
    this.isRightClick = false,
  });
}

class WordClickController extends Notifier<void> {
  WordClickMode _mode = WordClickMode.highlightVerse;

  void setMode(WordClickMode mode) {
    _mode = mode;
  }

  void handleClick(WidgetRef ref, WordClickContext ctx) {
    final highlighter = ref.read(highlightControllerProvider.notifier);
    final word = ctx.word;
    final pageNumber = ctx.page;
    final isCtrlPressed = ctx.ctrlPressed;

    // logger.info("Handling click for word: ${word.id} on page: $pageNumber, mode: $_mode");


    // switch (_mode) {
    //   case WordClickMode.highlightVerse:
    //     highlighter.highlightWords(
    //       pageNumber,
    //       ayahWordLocations,
    //       Colors.yellow.withOpacity(0.5),
    //     );
    //     break;
    //
    //   case WordClickMode.highlightSingle:
    //     highlighter.toggleWordsHighlight(pageNumber, [word.location]);
    //     break;
    //
    //   case WordClickMode.viewAyahTafsir:
    //   // Open tafsir for ctx.word.surah and ctx.word.ayah
    //     logger.fine("Open Tafsir for ${ctx.word.surah}:${ctx.word.ayah}");
    //     break;
    // }
  }

  @override
  void build() {} // no state needed
}
