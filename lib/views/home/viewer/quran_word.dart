import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/highlighter/highlighter_provider.dart';
import 'package:quran/providers/highlighter/word_highlight.dart';

class WordWidget extends ConsumerWidget {
  final Word word;
  final int pageNumber;
  final double fontSize;
  final String fontFamily;
  final List<String> ayahWordLocations;
  final void Function()? onTap;

  WordWidget({
    super.key,
    required this.word,
    required this.pageNumber,
    required this.fontSize,
    required this.ayahWordLocations,
    this.onTap,
  }) : fontFamily = Word.fontFamilyForPage(pageNumber);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlights = ref.watch(highlightControllerProvider).highlights[pageNumber] ?? [];
    final highlighter = ref.read(highlightControllerProvider.notifier);

    void defaultOnTap() {

    }

    final highlight = highlights.firstWhere(
      (h) => h.location == word.location,
      orElse: () => WordHighlight(location: word.location, color: Colors.transparent),
    );

    final isHighlighted = highlight.color != Colors.transparent;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
        if (word.isAyahNrSymbol) {
          highlighter.toggleWordsHighlight(pageNumber, ayahWordLocations);
        } else {
          if (isCtrlPressed) {
            highlighter.toggleWordsHighlight(pageNumber, [word.location]);
          } else {
            highlighter.toggleWordsHighlight(pageNumber, ayahWordLocations);
          }
        }

      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        decoration: isHighlighted ? BoxDecoration(color: highlight.color) : null,
        child: Text(
          word.glyphCode,
          style: TextStyle(fontSize: fontSize, fontFamily: fontFamily, color: Colors.black87),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
