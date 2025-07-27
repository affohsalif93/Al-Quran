import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum HighlightMode { highlight, focus }

class Highlight {
  final String label;
  final Color color;
  final int zIndex;
  final bool isFullHeight;

  Highlight({required this.label, required this.color, required this.isFullHeight, required this.zIndex});
}

class LabeledHighlight extends Highlight {
  final Set<(int page, String location)> highlights;

  LabeledHighlight({
    required this.highlights,
    required super.label,
    required super.color,
    required super.isFullHeight,
    required super.zIndex,
  });

  LabeledHighlight.fromHighlight(Highlight highlight, this.highlights)
    : super(
        label: highlight.label,
        color: highlight.color,
        isFullHeight: highlight.isFullHeight,
        zIndex: highlight.zIndex,
      );

  LabeledHighlight copyWith({
    String? label,
    Color? color,
    int? zIndex,
    bool? isFullHeight,
    Set<(int page, String location)>? highlights,
  }) {
    return LabeledHighlight(
      label: label ?? this.label,
      color: color ?? this.color,
      zIndex: zIndex ?? this.zIndex,
      isFullHeight: isFullHeight ?? this.isFullHeight,
      highlights: highlights ?? this.highlights,
    );
  }
}

class HighlighterState extends Equatable {
  final Map<String, LabeledHighlight> labels;
  final HighlightMode mode;

  const HighlighterState({required this.labels, required this.mode});

  factory HighlighterState.initial() {
    return HighlighterState(labels: {}, mode: HighlightMode.highlight);
  }

  HighlighterState copyWith({Map<String, LabeledHighlight>? labels, HighlightMode? mode}) {
    return HighlighterState(labels: labels ?? this.labels, mode: mode ?? this.mode);
  }

  bool isHighlighted(int page, String location) {
    return labels.values.any((s) => s.highlights.contains((page, location)));
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
