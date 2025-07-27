import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/highlighter/highlighter_provider.dart';
import 'package:quran/providers/quran_page_provider.dart';

class QuranWordWidget extends ConsumerWidget {
  final Word word;
  final int pageNumber;
  final double fontSize;
  final String fontFamily;
  final double lineHeight;
  final double paddingVertical;
  final void Function()? onTap;

  QuranWordWidget({
    super.key,
    required this.word,
    required this.pageNumber,
    required this.fontSize,
    required this.lineHeight,
    required this.paddingVertical,
    this.onTap,
  }) : fontFamily = Word.fontFamilyForPage(pageNumber);

  const QuranWordWidget.withFont({
    super.key,
    required this.word,
    required this.pageNumber,
    required this.fontSize,
    required this.fontFamily,
    required this.lineHeight,
    required this.paddingVertical,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlighterState = ref.watch(highlightControllerProvider);
    final quranPageController = ref.watch(quranPageControllerProvider(pageNumber).notifier);

    final wordHighlights =
        highlighterState.labels.values
            .where((source) => source.highlights.contains((pageNumber, word.location)))
            .toList();

    final fullHeightHighlights = wordHighlights.where((source) => source.isFullHeight).toList();
    fullHeightHighlights.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    final wordHeightHighlights = wordHighlights.where((source) => !source.isFullHeight).toList();
    wordHeightHighlights.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    final fullHeightHighlight = fullHeightHighlights.isNotEmpty ? fullHeightHighlights.first : null;
    final wordHeightHighlight = wordHeightHighlights.isNotEmpty ? wordHeightHighlights.first : null;

    final fullHeightHighlightColor = fullHeightHighlight?.color ?? Colors.transparent;
    final wordHeightHighlightColor = wordHeightHighlight?.color ?? Colors.transparent;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
        final isRightClick =
            event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton;

        final ctx = WordClickContext(
          word: word,
          page: pageNumber,
          isCtrlPressed: isCtrlPressed,
          isRightClick: isRightClick,
        );

        quranPageController.handleWordClick(ctx, ref);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: paddingVertical ),
        height: lineHeight,
        decoration: BoxDecoration(color: fullHeightHighlightColor),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(color: wordHeightHighlightColor),
          child: Text(
            word.glyphCode,
            style: TextStyle(fontSize: fontSize, fontFamily: fontFamily, color: Colors.black),
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }
}
