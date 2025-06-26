import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/highlighter/word_highlight.dart';
import 'package:quran/repositories/quran/quran_repository.dart';

class HighlightController extends StateNotifier<HighlighterState> {
  final Ref ref;
  late final QuranRepository repo;

  HighlightController(this.ref) : super(HighlighterState.initial()) {
    repo = ref.read(quranRepositoryProvider);
  }

  void highlightWords(int page, List<String> wordLocations, Color color) {
    final current = state.highlights;
    final existing = current[page] ?? [];

    final updated = [
      ...existing.where((h) => !wordLocations.contains(h.location)),
      ...wordLocations.map((location) => WordHighlight(location: location, color: color)),
    ];

    current[page] = updated;
    state = state.copyWith(highlights: current);
  }

  void clearHighlights(int page) {
    final current = state.highlights;
    current.remove(page);
    state = state.copyWith(highlights: current);
  }

  void clearWordHighlights(int page, List<String> wordLocations) {
    final current = Map<int, List<WordHighlight>>.from(state.highlights);
    final updated =
        (current[page] ?? []).where((h) => !wordLocations.contains(h.location)).toList();
    current[page] = updated;
    state = state.copyWith(highlights: current);
  }

  void clearWordHighlight(int page, String location) {
    final current = state.highlights;
    final updated = (current[page] ?? []).where((h) => h.location != location).toList();
    current[page] = updated;
    state = state.copyWith(highlights: current);
  }

  bool isHighlighted(int page, String location) {
    return state.highlights[page]?.any((h) => h.location == location) ?? false;
  }

  void toggleWordsHighlight(int page, List<String> wordLocations) {
    final current = state.highlights;
    final existing = current[page] ?? [];

    final updated = existing.where((h) => !wordLocations.contains(h.location)).toList();

    if (updated.length == existing.length) {
      updated.addAll(
        wordLocations.map(
          (location) => WordHighlight(location: location, color: Colors.yellow.withOpacity(0.5)),
        ),
      );
    }

    current[page] = updated;
    state = state.copyWith(highlights: current);
  }

  Color? highlightColor(int page, String location) {
    return state.highlights[page]
        ?.firstWhere(
          (h) => h.location == location,
          orElse: () => WordHighlight(location: "", color: Colors.transparent),
        )
        .color;
  }
}

enum HighlightMode { highlight, focus }

class HighlighterState extends Equatable {
  final Map<int, List<WordHighlight>> highlights;
  final List<WordHighlight> focusedHighlights = [];
  final HighlightMode mode;

  HighlighterState(this.highlights, this.mode);

  factory HighlighterState.initial() {
    return HighlighterState({}, HighlightMode.highlight);
  }

  HighlighterState copyWith({
    Map<int, List<WordHighlight>>? highlights,
    HighlightMode? mode,
  }) {
    return HighlighterState(
      highlights ?? this.highlights,
      mode ?? this.mode,
    );
  }

  bool isHighlighted(int page, String location) {
    return highlights[page]?.any((h) => h.location == location) ?? false;
  }

  HighlighterState toggleHighlightMode() {
    return copyWith(
      mode: mode == HighlightMode.highlight ? HighlightMode.focus : HighlightMode.highlight,
    );
  }

  @override
  List<Object?> get props => [highlights, mode];

}
