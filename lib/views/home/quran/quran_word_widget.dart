import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/color_picker/color_picker_provider.dart';
import 'package:quran/providers/highlighter/highlighter_provider.dart';
import 'package:quran/providers/quran/quran_page_provider.dart';
import 'package:quran/providers/quran/quran_page_state.dart';

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
    final quranDualPageController = ref.watch(quranDualPageProvider.notifier);

    // Get persistent highlights for this location
    final persistentHighlights = ref.watch(
      highlightsForLocationProvider((widget.pageNumber, widget.word.location)),
    );

    // Separate full and partial highlights
    final fullHighlights = persistentHighlights.where((h) => !h.isPartial).toList();
    final partialHighlights = persistentHighlights.where((h) => h.isPartial).toList();

    // Get the most recent full highlight (if any) for background color
    final mostRecentFullHighlight =
        fullHighlights.isNotEmpty
            ? fullHighlights.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b)
            : null;

    // Check for tafsir range highlight
    final tafsirHighlight = ref.watch(
      tafsirRangeHighlightProvider((widget.word.surah, widget.word.ayah)),
    );

    // Priority: persistent highlights > tafsir highlight > transparent
    final backgroundColor =
        tafsirHighlight?.color ?? mostRecentFullHighlight?.color ?? Colors.transparent;

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

          quranDualPageController.handleWordClick(ctx, ref);
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
        decoration: BoxDecoration(color: backgroundColor),
        child: Stack(
          children: [
            // Partial highlights go first (bottom layer)
            ...partialHighlights.map((highlight) => _buildPersistentPartialHighlight(highlight)),
            // Drag preview goes second
            if (_isDragging && _dragStartLocalX != null) _buildDragPreview(),
            // Text goes last (top layer - always visible above highlights)
            Text(
              key: _textKey,
              widget.word.glyph,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontFamily: widget.fontFamily,
                color: Colors.black,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersistentPartialHighlight(dynamic highlight) {
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

  Widget _buildDragPreview() {
    final RenderBox? renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || _dragStartLocalX == null) {
      return const SizedBox.shrink();
    }

    final textWidth = renderBox.size.width;
    final startX = _dragStartLocalX!;
    final endX = _dragEndLocalX ?? startX; // Use start position if no end position yet

    double startPercentage = (startX / textWidth).clamp(0.0, 1.0);
    double endPercentage = (endX / textWidth).clamp(0.0, 1.0);

    if (startPercentage > endPercentage) {
      final temp = startPercentage;
      startPercentage = endPercentage;
      endPercentage = temp;
    }

    // Ensure minimum width for visibility
    if (endPercentage - startPercentage < 0.02) {
      endPercentage = (startPercentage + 0.02).clamp(0.0, 1.0);
    }

    final selectedColor = ref.read(selectedColorProvider);
    final previewColor = selectedColor?.withOpacity(0.5) ?? Colors.blue.withOpacity(0.3);

    return Positioned.fill(
      child: CustomPaint(
        painter: PartialHighlightPainter(
          startPercentage: startPercentage,
          endPercentage: endPercentage,
          color: previewColor,
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
        final persistentHighlightController = ref.read(highlightControllerProvider.notifier);
        final selectedColor = ref.read(selectedColorProvider);
        persistentHighlightController.addPartialHighlight(
          page: widget.pageNumber,
          location: widget.word.location,
          startPercentage: startPercentage,
          endPercentage: endPercentage,
          color: selectedColor,
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

      // Find partial highlights at this location and remove the one that contains the click point
      final persistentHighlights = ref.read(
        highlightsForLocationProvider((widget.pageNumber, widget.word.location)),
      );

      final partialHighlights = persistentHighlights.where((h) => h.isPartial).toList();

      for (final highlight in partialHighlights) {
        final startPercentage = highlight.startPercentage ?? 0.0;
        final endPercentage = highlight.endPercentage ?? 1.0;

        if (clickPercentage >= startPercentage && clickPercentage <= endPercentage) {
          final persistentHighlightController = ref.read(highlightControllerProvider.notifier);
          persistentHighlightController.deleteHighlight(highlight.id);
          break;
        }
      }
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

    // Make highlight not full height - leave some margin
    final verticalMargin = size.height * 0.1;
    final rect = Rect.fromLTRB(left, verticalMargin, right, size.height - verticalMargin);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(PartialHighlightPainter oldDelegate) {
    return oldDelegate.startPercentage != startPercentage ||
        oldDelegate.endPercentage != endPercentage ||
        oldDelegate.color != color;
  }
}
