import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/models/highlight/saved_highlight.dart';
import 'package:quran/providers/highlighter/highlight_controller.dart';
import 'package:quran/providers/highlighter/highlighter_state.dart';

// Main highlight controller provider
final highlightControllerProvider = StateNotifierProvider<HighlightController, HighlighterState>((ref) {
  return HighlightController(ref);
});

// Convenience providers for accessing highlight data
final highlightsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(highlightControllerProvider).isLoading;
});

final highlightsErrorProvider = Provider<String?>((ref) {
  return ref.watch(highlightControllerProvider).error;
});

final hasHighlightsProvider = Provider<bool>((ref) {
  return ref.watch(highlightControllerProvider).hasHighlights;
});

final totalHighlightsCountProvider = Provider<int>((ref) {
  return ref.watch(highlightControllerProvider).totalHighlights;
});

// Provider to get highlights for a specific page (family provider)
final highlightsForPageProvider = Provider.family<List<SavedHighlight>, int>((ref, page) {
  return ref.watch(highlightControllerProvider).getHighlightsForPage(page);
});

// Provider to get highlights for a specific location (family provider)
final highlightsForLocationProvider = Provider.family<List<SavedHighlight>, (int, String)>((ref, params) {
  final (page, location) = params;
  return ref.watch(highlightControllerProvider).getHighlightsForLocation(page, location);
});

// Provider to check if a location has highlights (family provider)
final hasHighlightAtLocationProvider = Provider.family<bool, (int, String)>((ref, params) {
  final (page, location) = params;
  return ref.watch(highlightControllerProvider).hasHighlightAtLocation(page, location);
});

// Provider to get all pages with highlights
final pagesWithHighlightsProvider = Provider<Set<int>>((ref) {
  return ref.watch(highlightControllerProvider).pagesWithHighlights;
});

// Provider to get highlights for multiple pages (family provider)
final highlightsForPagesProvider = Provider.family<List<SavedHighlight>, List<int>>((ref, pages) {
  return ref.watch(highlightControllerProvider).getHighlightsForPages(pages);
});