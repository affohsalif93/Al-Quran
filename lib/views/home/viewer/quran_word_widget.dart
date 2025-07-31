import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/highlighter/highlighter_provider.dart';
import 'package:quran/providers/highlighter/highlighter_state.dart';
import 'package:quran/providers/quran_page_provider.dart';

class QuranWordWidget extends ConsumerStatefulWidget {
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
  ConsumerState<QuranWordWidget> createState() => _QuranWordWidgetState();
}

class _QuranWordWidgetState extends ConsumerState<QuranWordWidget> {
  bool _isDragging = false;
  double? _dragStartLocalX;
  double? _dragEndLocalX;
  final GlobalKey _textKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final highlighterState = ref.watch(highlightControllerProvider);
    final highlighterController = ref.watch(highlightControllerProvider.notifier);
    final quranPageController = ref.watch(quranPageControllerProvider(widget.pageNumber).notifier);

    final wordHighlights =
        highlighterState.labels.values
            .where(
              (source) => source.highlights.contains((widget.pageNumber, widget.word.location)),
            )
            .toList();

    final partialHighlights = highlighterController.getPartialHighlights(
      widget.pageNumber,
      widget.word.location,
    );

    final fullHeightHighlights = wordHighlights.where((source) => source.isFullHeight).toList();
    fullHeightHighlights.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    final wordHeightHighlights = wordHighlights.where((source) => !source.isFullHeight).toList();
    wordHeightHighlights.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    final fullHeightHighlight = fullHeightHighlights.isNotEmpty ? fullHeightHighlights.last : null;
    final wordHeightHighlight = wordHeightHighlights.isNotEmpty ? wordHeightHighlights.last : null;

    final fullHeightHighlightColor = fullHeightHighlight?.color ?? Colors.transparent;
    final wordHeightHighlightColor = wordHeightHighlight?.color ?? Colors.transparent;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
        final isAltPressed = HardwareKeyboard.instance.isAltPressed;
        final isRightClick =
            event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton;

        if (isAltPressed && isRightClick) {
          _handlePartialHighlightDeletion(event);
        } else if (isAltPressed && !isRightClick) {
          _startPartialHighlight(event);
        } else {
          final ctx = WordClickContext(
            word: widget.word,
            page: widget.pageNumber,
            isCtrlPressed: isCtrlPressed,
            isRightClick: isRightClick,
            isAltPressed: isAltPressed,
          );

          quranPageController.handleWordClick(ctx, ref);
        }
      },
      onPointerMove: (event) {
        if (_isDragging) {
          _updatePartialHighlight(event);
        }
      },
      onPointerUp: (event) {
        if (_isDragging) {
          _endPartialHighlight(event);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: widget.paddingVertical, horizontal: 0),
        height: widget.lineHeight,
        decoration: BoxDecoration(color: fullHeightHighlightColor),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(color: wordHeightHighlightColor),
              child: Text(
                key: _textKey,
                widget.word.glyphCode,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontFamily: widget.fontFamily,
                  color: Colors.black,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            ...partialHighlights.map((highlight) => _buildPartialHighlight(highlight)),
          ],
        ),
      ),
    );
  }

  Widget _buildPartialHighlight(Highlight highlight) {
    return Positioned.fill(
      child: CustomPaint(
        painter: PartialHighlightPainter(
          startPercentage: highlight.startPercentage ?? 0.0,
          endPercentage: highlight.endPercentage ?? 1.0,
          color: highlight.color,
        ),
      ),
    );
  }

  void _startPartialHighlight(PointerDownEvent event) {
    final RenderBox? renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(event.position);
      _dragStartLocalX = localPosition.dx;
      _isDragging = true;
    }
  }

  void _updatePartialHighlight(PointerMoveEvent event) {
    final RenderBox? renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && _dragStartLocalX != null) {
      final localPosition = renderBox.globalToLocal(event.position);
      _dragEndLocalX = localPosition.dx;
      setState(() {});
    }
  }

  void _endPartialHighlight(PointerUpEvent event) {
    final RenderBox? renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && _dragStartLocalX != null) {
      final localPosition = renderBox.globalToLocal(event.position);
      _dragEndLocalX = localPosition.dx;

      final textWidth = renderBox.size.width;
      final startX = _dragStartLocalX!;
      final endX = _dragEndLocalX!;

      double startPercentage = (startX / textWidth).clamp(0.0, 1.0);
      double endPercentage = (endX / textWidth).clamp(0.0, 1.0);

      if (startPercentage > endPercentage) {
        final temp = startPercentage;
        startPercentage = endPercentage;
        endPercentage = temp;
      }

      if (endPercentage - startPercentage > 0.05) {
        final highlighterController = ref.read(highlightControllerProvider.notifier);
        highlighterController.addPartialHighlight(
          highlight: partialHighlight,
          page: widget.pageNumber,
          location: widget.word.location,
          startPercentage: startPercentage,
          endPercentage: endPercentage,
        );
      }
    }

    _isDragging = false;
    _dragStartLocalX = null;
    _dragEndLocalX = null;
  }

  void _handlePartialHighlightDeletion(PointerDownEvent event) {
    final RenderBox? renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(event.position);
      final textWidth = renderBox.size.width;
      final clickPercentage = (localPosition.dx / textWidth).clamp(0.0, 1.0);

      final highlighterController = ref.read(highlightControllerProvider.notifier);
      highlighterController.removePartialHighlightAt(
        widget.pageNumber,
        widget.word.location,
        clickPercentage,
      );
    }
  }
}

class PartialHighlightPainter extends CustomPainter {
  final double startPercentage;
  final double endPercentage;
  final Color color;

  PartialHighlightPainter({
    required this.startPercentage,
    required this.endPercentage,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    double left, right;
    left = size.width * startPercentage;
    right = size.width * endPercentage;

    final rect = Rect.fromLTRB(left, 0, right, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(PartialHighlightPainter oldDelegate) {
    return oldDelegate.startPercentage != startPercentage ||
        oldDelegate.endPercentage != endPercentage ||
        oldDelegate.color != color;
  }
}
