import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/highlighter/word_highlight.dart';
import 'package:quran/repositories/quran/quran_repository.dart';


class HighlightController extends Notifier<Map<int, List<WordHighlight>>> {
  late final QuranRepository repo;

  @override
  Map<int, List<WordHighlight>> build() {
    repo = ref.read(quranRepositoryProvider);
    return {};
  }

  void highlightWords(int page, List<String> wordLocations, Color color) {
    final current = Map<int, List<WordHighlight>>.from(state);
    final existing = current[page] ?? [];

    final updated = [
      ...existing.where((h) => !wordLocations.contains(h.location)),
      ...wordLocations.map(
            (location) => WordHighlight(location: location, color: color),
      ),
    ];

    current[page] = updated;
    state = current;
  }

  void clearHighlights(int page) {
    final current = Map<int, List<WordHighlight>>.from(state);
    current.remove(page);
    state = current;
  }

  void clearWordHighlights(int page, List<String> wordLocations) {
    final current = Map<int, List<WordHighlight>>.from(state);
    final updated = (current[page] ?? []).where((h) => !wordLocations.contains(h.location)).toList();
    current[page] = updated;
    state = current;
  }

  void clearWordHighlight(int page, String location) {
    final current = Map<int, List<WordHighlight>>.from(state);
    final updated =
    (current[page] ?? []).where((h) => h.location != location).toList();
    current[page] = updated;
    state = current;
  }

  bool isHighlighted(int page, String location) {
    return state[page]?.any((h) => h.location == location) ?? false;
  }

  Color? highlightColor(int page, String location) {
    return state[page]
        ?.firstWhere(
          (h) => h.location == location,
      orElse: () => WordHighlight(location: "", color: Colors.transparent),
    )
        .color;
  }
}
