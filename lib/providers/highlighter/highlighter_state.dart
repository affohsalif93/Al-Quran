import 'package:equatable/equatable.dart';
import 'package:quran/models/highlight/saved_highlight.dart';

class HighlighterState extends Equatable {
  final Map<int, List<SavedHighlight>> pageHighlights; // page -> highlights
  final Map<String, SavedHighlight> highlightById; // id -> highlight
  final bool isLoading;
  final String? error;

  const HighlighterState({
    this.pageHighlights = const {},
    this.highlightById = const {},
    this.isLoading = false,
    this.error,
  });

  // Initial state
  factory HighlighterState.initial() {
    return const HighlighterState();
  }

  // Copy with method
  HighlighterState copyWith({
    Map<int, List<SavedHighlight>>? pageHighlights,
    Map<String, SavedHighlight>? highlightById,
    bool? isLoading,
    String? error,
  }) {
    return HighlighterState(
      pageHighlights: pageHighlights ?? this.pageHighlights,
      highlightById: highlightById ?? this.highlightById,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Get highlights for a specific page
  List<SavedHighlight> getHighlightsForPage(int page) {
    return pageHighlights[page] ?? [];
  }

  // Get highlights for a specific location on a page
  List<SavedHighlight> getHighlightsForLocation(int page, String location) {
    final pageHighlightsList = pageHighlights[page] ?? [];
    return pageHighlightsList.where((h) => h.location == location).toList();
  }

  // Check if a location has any highlights
  bool hasHighlightAtLocation(int page, String location) {
    final pageHighlightsList = pageHighlights[page] ?? [];
    return pageHighlightsList.any((h) => h.location == location);
  }

  // Get all highlights for multiple pages
  List<SavedHighlight> getHighlightsForPages(List<int> pages) {
    final List<SavedHighlight> result = [];
    for (final page in pages) {
      result.addAll(getHighlightsForPage(page));
    }
    return result;
  }

  // Get total number of highlights
  int get totalHighlights => highlightById.length;

  // Check if state has any highlights
  bool get hasHighlights => highlightById.isNotEmpty;

  // Get all unique pages with highlights
  Set<int> get pagesWithHighlights => pageHighlights.keys.toSet();

  @override
  List<Object?> get props => [
    pageHighlights,
    highlightById,
    isLoading,
    error,
  ];

  @override
  bool get stringify => true;
}