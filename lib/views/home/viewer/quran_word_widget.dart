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
  final void Function()? onTap;

  QuranWordWidget({
    super.key,
    required this.word,
    required this.pageNumber,
    required this.fontSize,
    this.onTap,
  }) : fontFamily = Word.fontFamilyForPage(pageNumber);

  QuranWordWidget.withFont({
    super.key,
    required this.word,
    required this.pageNumber,
    required this.fontSize,
    required this.fontFamily,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlighterState = ref.watch(highlightControllerProvider);
    final quranPageController = ref.watch(quranPageControllerProvider.notifier);

    final wordHighlights = highlighterState.labels.values
        .where((source) => source.highlights.contains((pageNumber, word.location)))
        .toList();


    final Color? backgroundColor = wordHighlights.isNotEmpty
        ? wordHighlights.last.color
        : null;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
        final isRightClick = event.kind == PointerDeviceKind.mouse &&
            event.buttons == kSecondaryMouseButton;

        final ctx = WordClickContext(
          word: word,
          page: pageNumber,
          isCtrlPressed: isCtrlPressed,
          isRightClick: isRightClick,
        );

        quranPageController.handleWordClick(ctx, ref);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
        ),
        child: Text(
          word.glyphCode,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: fontFamily,
            color: Colors.black87,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
