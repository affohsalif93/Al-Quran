import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum HighlightMode { highlight, focus }

class LabeledHighlight {
  final String label;
  final Color color;
  final Set<(int page, String location)> highlights;

  LabeledHighlight({
    required this.label,
    required this.color,
    required this.highlights,
  });

  LabeledHighlight copyWith({
    String? name,
    Color? color,
    Set<(int page, String location)>? highlights,
  }) {
    return LabeledHighlight(
      label: name ?? this.label,
      color: color ?? this.color,
      highlights: highlights ?? this.highlights,
    );
  }
}

class HighlighterState extends Equatable {
  final Map<String, LabeledHighlight> labels;
  final HighlightMode mode;

  const HighlighterState({
    required this.labels,
    required this.mode,
  });

  factory HighlighterState.initial() {
    return HighlighterState(
      labels: {},
      mode: HighlightMode.focus,
    );
  }

  HighlighterState copyWith({
    Map<String, LabeledHighlight>? labels,
    HighlightMode? mode,
  }) {
    return HighlighterState(
      labels: labels ?? this.labels,
      mode: mode ?? this.mode,
    );
  }

  bool isHighlighted(int page, String location) {
    return labels.values.any(
          (s) => s.highlights.contains((page, location)),
    );
  }

  Set<(String label, String location)> highlightsOnPage(int page) {
    final result = <(String, String)>{};
    for (final entry in labels.entries) {
      for (final hl in entry.value.highlights) {
        if (hl.$1 == page) result.add((entry.key, hl.$2));
      }
    }
    return result;
  }

  Color? highlightColor(int page, String location) {
    for (final label in labels.values) {
      if (label.highlights.contains((page, location))) {
        return label.color;
      }
    }
    return null;
  }

  HighlighterState toggleHighlightMode() {
    return copyWith(
      mode: mode == HighlightMode.highlight ? HighlightMode.focus : HighlightMode.highlight,
    );
  }

  @override
  List<Object?> get props => [labels, mode];
}
