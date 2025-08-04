import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/ayah.dart';
import 'package:quran/models/quran/page_data.dart';
import 'package:quran/models/quran/word.dart';
import 'package:quran/providers/color_picker/color_picker_provider.dart';

// Old Highlight template class (kept for zIndex and other properties)
class Highlight {
  final String label;
  final Color color;
  final int zIndex;
  final bool isFullHeight;
  final bool isPartial;
  final double? startPercentage;
  final double? endPercentage;
  final String? id;

  Highlight({
    required this.label,
    required this.color,
    required this.zIndex,
    this.isFullHeight = false,
    this.isPartial = false,
    this.startPercentage,
    this.endPercentage,
    this.id,
  });

  Highlight copyWith({
    String? label,
    Color? color,
    int? zIndex,
    bool? isFullHeight,
    bool? isPartial,
    double? startPercentage,
    double? endPercentage,
    String? id,
  }) {
    return Highlight(
      label: label ?? this.label,
      color: color ?? this.color,
      zIndex: zIndex ?? this.zIndex,
      isFullHeight: isFullHeight ?? this.isFullHeight,
      isPartial: isPartial ?? this.isPartial,
      startPercentage: startPercentage ?? this.startPercentage,
      endPercentage: endPercentage ?? this.endPercentage,
      id: id ?? this.id,
    );
  }
}

class WordClickContext {
  final Word word;
  final int page;
  final bool isCtrlPressed;
  final bool isRightClick;
  final bool isAltPressed;

  WordClickContext({
    required this.word,
    required this.page,
    this.isCtrlPressed = false,
    this.isRightClick = false,
    this.isAltPressed = false,
  });
}

final focusHighlight = Highlight(
  label: "focus",
  color: Colors.grey.withValues(alpha: 0.3),
  zIndex: 0,
  isFullHeight: true,
);

final ayahHighlight = Highlight(
  label: "ayah",
  color: Colors.yellow.withValues(alpha: 0.3),
  zIndex: 1,
);

final partialHighlight = Highlight(
  label: "partial",
  color: Colors.green.withValues(alpha: 0.3),
  zIndex: 5,
);

// This will be replaced by a provider-based highlight
final wordHighlight = Highlight(
  label: "word",
  color: Colors.orange.withValues(alpha: 0.3),
  zIndex: 2,
);

// Provider for dynamic word highlight based on selected color
final wordHighlightProvider = Provider<Highlight>((ref) {
  final selectedColor = ref.watch(selectedColorProvider);
  return Highlight(
    label: "word",
    color: selectedColor ?? Colors.orange.withValues(alpha: 0.3),
    zIndex: 2,
  );
});

enum HighlightAction {
  highlightWord, // ctrl + left click + !isAyahNrSymbol
  highlightAyah, // ctrl + left click + isAyahNrSymbol
  selectAyah, // ctrl + left click
  removeWordHighlight, // ctrl + right click !isAyahNrSymbol
  removeAyahHighlight, // ctrl + right click + isAyahNrSymbol
}

class QuranPageState {
  final Map<int, QuranPageData> pages;

  QuranPageState({required this.pages});

  factory QuranPageState.initial() {
    return QuranPageState(pages: {});
  }

  QuranPageState copyWith({Map<int, QuranPageData>? pages}) {
    return QuranPageState(pages: pages ?? this.pages);
  }

  QuranPageData? getPageData(int pageNumber) {
    final pageData = pages[pageNumber];
    return (pageData != null && !pageData.isEmpty) ? pageData : null;
  }

  List<Word> getWordsForAyah(int pageNumber, int surah, int ayah) {
    final data = getPageData(pageNumber);
    return data?.words.where((word) => word.surah == surah && word.ayah == ayah).toList() ?? [];
  }

  Ayah getAyah(int pageNumber, int surah, int ayah) {
    final pageData = getPageData(pageNumber);
    return pageData!.getAyah(surah, ayah);
  }
}
