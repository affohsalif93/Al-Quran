import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum HighlightMode { highlight, focus }

class Highlight {
  final String label;
  final Color color;
  final int zIndex;
  final bool isFullHeight;
  final bool isPartial;
  final double? startPercentage;
  final double? endPercentage;
  final String? id; // Unique identifier for partial highlights

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

class LabeledHighlight extends Highlight {
  final Set<(int page, String location)> highlights;
  final Map<(int page, String location), List<Highlight>> partialHighlights;

  LabeledHighlight({
    required this.highlights,
    required super.label,
    required super.color,
    required super.isFullHeight,
    required super.zIndex,
    super.isPartial = false,
    super.startPercentage,
    super.endPercentage,
    super.id,
    this.partialHighlights = const {},
  });

  LabeledHighlight.fromHighlight(Highlight highlight, this.highlights, {this.partialHighlights = const {}})
    : super(
        label: highlight.label,
        color: highlight.color,
        isFullHeight: highlight.isFullHeight,
        zIndex: highlight.zIndex,
        isPartial: highlight.isPartial,
        startPercentage: highlight.startPercentage,
        endPercentage: highlight.endPercentage,
        id: highlight.id,
      );

  LabeledHighlight copyWith({
    String? label,
    Color? color,
    int? zIndex,
    bool? isFullHeight,
    Set<(int page, String location)>? highlights,
    bool? isPartial,
    double? startPercentage,
    double? endPercentage,
    String? id,
    Map<(int page, String location), List<Highlight>>? partialHighlights,
  }) {
    return LabeledHighlight(
      label: label ?? this.label,
      color: color ?? this.color,
      zIndex: zIndex ?? this.zIndex,
      isFullHeight: isFullHeight ?? this.isFullHeight,
      highlights: highlights ?? this.highlights,
      isPartial: isPartial ?? this.isPartial,
      startPercentage: startPercentage ?? this.startPercentage,
      endPercentage: endPercentage ?? this.endPercentage,
      id: id ?? this.id,
      partialHighlights: partialHighlights ?? this.partialHighlights,
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

  List<Highlight> getPartialHighlights(int page, String location) {
    final result = <Highlight>[];
    for (final label in labels.values) {
      final partialList = label.partialHighlights[(page, location)];
      if (partialList != null) {
        result.addAll(partialList);
      }
    }
    result.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return result;
  }

  Highlight? findPartialHighlightById(int page, String location, String id) {
    for (final label in labels.values) {
      final partialList = label.partialHighlights[(page, location)];
      if (partialList != null) {
        for (final highlight in partialList) {
          if (highlight.id == id) {
            return highlight;
          }
        }
      }
    }
    return null;
  }

  Highlight? findPartialHighlightAt(int page, String location, double percentage) {
    final partialHighlights = getPartialHighlights(page, location);
    for (final highlight in partialHighlights) {
      if (highlight.startPercentage != null && highlight.endPercentage != null) {
        if (percentage >= highlight.startPercentage! && percentage <= highlight.endPercentage!) {
          return highlight;
        }
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
