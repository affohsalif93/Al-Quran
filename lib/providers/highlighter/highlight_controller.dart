import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/providers/highlighter/highlighter_state.dart';
import 'package:quran/repositories/quran/quran_repository.dart';

class HighlightController extends StateNotifier<HighlighterState> {
  final Ref ref;
  late final QuranRepository repo;

  HighlightController(this.ref) : super(HighlighterState.initial()) {
    repo = ref.read(quranRepositoryProvider);
  }

  void highlightWords({
    required Highlight highlight,
    required List<(int page, String location)> targets,
  }) {
    final current = Map<String, LabeledHighlight>.from(state.labels);
    final existing = current[highlight.label];

    final updatedHighlights = {...(existing?.highlights ?? {})}..addAll(targets);

    current[highlight.label] = LabeledHighlight.fromHighlight(highlight, updatedHighlights);
    state = state.copyWith(labels: current);
  }

  Set<(int page, String location)> getWordsForLabel(String label) {
    return state.labels[label]?.highlights ?? {};
  }

  void toggleWordsHighlight({
    required Highlight highlight,
    required List<(int page, String location)> targets,
  }) {
    final current = Map<String, LabeledHighlight>.from(state.labels);
    final existing = current[highlight.label];

    final existingSet = existing?.highlights ?? {};
    final newSet = Set.of(existingSet);

    bool allPresent = targets.every(newSet.contains);

    if (allPresent) {
      newSet.removeAll(targets);
    } else {
      newSet.addAll(targets);
    }

    current[highlight.label] = LabeledHighlight.fromHighlight(highlight, newSet);
    state = state.copyWith(labels: current);
  }

  void clearAllForLabel(String label) {
    final current = Map<String, LabeledHighlight>.from(state.labels);
    current.remove(label);
    state = state.copyWith(labels: current);
  }

  void clearSpecificHighlights(String label, List<(int page, String location)> targets) {
    final current = Map<String, LabeledHighlight>.from(state.labels);
    final existing = current[label];

    if (existing == null) return;

    final updated = Set.of(existing.highlights)..removeAll(targets);
    current[label] = existing.copyWith(highlights: updated);
    state = state.copyWith(labels: current);
  }

  bool isHighlighted(int page, String location) {
    return state.isHighlighted(page, location);
  }

  Color? highlightColor(int page, String location) {
    return state.highlightColor(page, location);
  }

  void setHighlightMode(HighlightMode mode) {
    state = state.copyWith(mode: mode);
  }
}
