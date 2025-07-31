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

  void removeWordsHighlight({
    required Highlight highlight,
    required List<(int page, String location)> targets,
  }) {
    final current = Map<String, LabeledHighlight>.from(state.labels);
    final existing = current[highlight.label];
    final existingSet = existing?.highlights ?? {};
    final newSet = Set.of(existingSet);
    newSet.removeAll(targets);

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

  void addPartialHighlight({
    required Highlight highlight,
    required int page,
    required String location,
    required double startPercentage,
    required double endPercentage,
  }) {
    final current = Map<String, LabeledHighlight>.from(state.labels);
    final existing = current[highlight.label];

    // Create unique ID for this partial highlight
    final id = '${DateTime.now().millisecondsSinceEpoch}_${startPercentage}_${endPercentage}';

    final partialHighlight = highlight.copyWith(
      isPartial: true,
      startPercentage: startPercentage,
      endPercentage: endPercentage,
      id: id,
    );

    final updatedPartialHighlights = Map<(int, String), List<Highlight>>.from(
      existing?.partialHighlights ?? {},
    );

    final existingList = List<Highlight>.from(updatedPartialHighlights[(page, location)] ?? []);
    existingList.add(partialHighlight);
    updatedPartialHighlights[(page, location)] = existingList;

    if (existing != null) {
      current[highlight.label] = existing.copyWith(partialHighlights: updatedPartialHighlights);
    } else {
      current[highlight.label] = LabeledHighlight.fromHighlight(
        highlight,
        {},
        partialHighlights: updatedPartialHighlights,
      );
    }

    state = state.copyWith(labels: current);
  }

  void removePartialHighlightById(String id) {
    final current = Map<String, LabeledHighlight>.from(state.labels);

    for (final entry in current.entries) {
      final labelKey = entry.key;
      final labeledHighlight = entry.value;
      bool found = false;

      final updatedPartialHighlights = Map<(int, String), List<Highlight>>.from(
        labeledHighlight.partialHighlights,
      );

      for (final partialEntry in updatedPartialHighlights.entries) {
        final wordKey = partialEntry.key;
        final highlights = partialEntry.value;

        final updatedList = highlights.where((h) => h.id != id).toList();
        if (updatedList.length != highlights.length) {
          found = true;
          if (updatedList.isEmpty) {
            updatedPartialHighlights.remove(wordKey);
          } else {
            updatedPartialHighlights[wordKey] = updatedList;
          }
          break;
        }
      }

      if (found) {
        current[labelKey] = labeledHighlight.copyWith(partialHighlights: updatedPartialHighlights);
        break;
      }
    }

    state = state.copyWith(labels: current);
  }

  void removePartialHighlightAt(int page, String location, double percentage) {
    final highlightToRemove = state.findPartialHighlightAt(page, location, percentage);
    if (highlightToRemove?.id != null) {
      removePartialHighlightById(highlightToRemove!.id!);
    }
  }

  List<Highlight> getPartialHighlights(int page, String location) {
    return state.getPartialHighlights(page, location);
  }

  Highlight? findPartialHighlightAt(int page, String location, double percentage) {
    return state.findPartialHighlightAt(page, location, percentage);
  }
}
