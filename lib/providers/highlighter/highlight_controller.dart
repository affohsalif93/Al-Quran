import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/highlighter/highlighter_provider.dart';
import 'package:quran/providers/highlighter/word_highlight.dart';

class HighlightController {
  final WidgetRef ref;

  HighlightController(this.ref);

  Map<int, List<WordHighlight>> get _highlights =>
      ref.read(pageHighlightsProvider);

  void highlightWords(int page, List<String> wordLocations, Color color) {
    final current = Map<int, List<WordHighlight>>.from(_highlights);
    final existing = current[page] ?? [];

    final updated = [
      ...existing.where((h) => !wordLocations.contains(h.location)),
      ...wordLocations.map(
        (location) => WordHighlight(location: location, color: color),
      ),
    ];

    current[page] = updated;
    ref.read(pageHighlightsProvider.notifier).state = current;
  }

  void clearHighlights(int page) {
    final current = Map<int, List<WordHighlight>>.from(_highlights);
    current.remove(page);
    ref.read(pageHighlightsProvider.notifier).state = current;
  }

  /// Remove highlight for one specific word
  void clearWordHighlight(int page, String location) {
    final current = Map<int, List<WordHighlight>>.from(_highlights);
    final updated =
        (current[page] ?? []).where((h) => h.location != location).toList();
    current[page] = updated;
    ref.read(pageHighlightsProvider.notifier).state = current;
  }

  /// Shortcut for highlighting a full verse
  void highlightVerse(int page, List<String> verseWordLocations, Color color) {
    highlightWords(page, verseWordLocations, color);
  }

  /// Check if a specific word is highlighted
  bool isHighlighted(int page, String location) {
    return _highlights[page]?.any((h) => h.location == location) ?? false;
  }

  /// Get the highlight color (or null) for a word
  Color? highlightColor(int page, String location) {
    return _highlights[page]
        ?.firstWhere(
          (h) => h.location == location,
          orElse: () => WordHighlight(location: "", color: Colors.transparent),
        )
        .color;
  }
}
