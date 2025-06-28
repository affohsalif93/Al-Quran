import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/highlighter/highlighter_provider.dart';
import 'package:quran/providers/highlighter/word_highlight.dart';
import 'package:quran/providers/word_click_provider.dart';

class QuranWordWidget extends ConsumerWidget {
  final Word word;
  final int pageNumber;
  final double fontSize;
  final String fontFamily;
  final List<String> ayahWordLocations;
  final void Function()? onTap;

  QuranWordWidget({
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
    final wordClickController = ref.watch(wordClickControllerProvider.notifier);

    final highlight = highlights.firstWhere(
      (h) => h.location == word.location,
      orElse: () => WordHighlight(location: word.location, color: Colors.transparent),
    );

    final isHighlighted = highlight.color != Colors.transparent;
    
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
        final isRightClick =
            event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton;;

        final ctx = WordClickContext(
          word: word,
          page: pageNumber,
          ctrlPressed: isCtrlPressed,
          isRightClick: isRightClick,
        );

        wordClickController.handleClick(ref, ctx);
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
