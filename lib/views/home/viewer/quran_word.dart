import 'package:flutter/material.dart';
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
    final highlights = ref.watch(highlightControllerProvider)[pageNumber] ?? [];
    final highlighter = ref.read(highlightControllerProvider.notifier);

    void defaultOnTap() {
      if (word.isAyahNrSymbol) {
        if (highlighter.isHighlighted(pageNumber, word.location)) {
          highlighter.clearWordHighlights(pageNumber, ayahWordLocations);
        } else {
          highlighter.highlightWords(pageNumber, ayahWordLocations, Colors.yellow.withOpacity(0.5));
        }
      } else {
        if (highlighter.isHighlighted(pageNumber, word.location)) {
          highlighter.clearWordHighlight(pageNumber, word.location);
        } else {
          highlighter.highlightWords(pageNumber, [word.location], Colors.yellow.withOpacity(0.5));
        }
      }
    }

    final highlight = highlights.firstWhere(
      (h) => h.location == word.location,
      orElse: () => WordHighlight(location: word.location, color: Colors.transparent),
    );

    final isHighlighted = highlight.color != Colors.transparent;

    return GestureDetector(
      onTap: onTap ?? defaultOnTap,
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
