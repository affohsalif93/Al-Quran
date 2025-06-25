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
  final void Function(Word word)? onTap;

  WordWidget({
    super.key,
    required this.word,
    required this.pageNumber,
    required this.fontSize,
    this.onTap,
  }) : fontFamily = Word.fontFamilyForPage(pageNumber);

   void defaultOnTap(Word word) {
    logger.fine("font $fontFamily Tapped on word at location: ${word.location}, glyph: ${word.glyphCode}");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlights = ref.watch(pageHighlightsProvider)[pageNumber] ?? [];

    final highlight = highlights.firstWhere(
      (h) => h.location == word.location,
      orElse: () => WordHighlight(location: word.location, color: Colors.transparent),
    );

    final isHighlighted = highlight.color != Colors.transparent;

    return GestureDetector(
      onTap: () => (onTap ?? defaultOnTap).call(word),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        decoration:
            isHighlighted
                ? BoxDecoration(color: highlight.color, borderRadius: BorderRadius.circular(4))
                : null,
        child: Text(
          word.glyphCode,
          style: TextStyle(fontSize: fontSize, fontFamily: fontFamily, color: Colors.black87),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
