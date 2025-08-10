import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/highlight/saved_highlight.dart';
import 'package:quran/providers/color_picker/color_picker_provider.dart';
import 'package:quran/providers/highlighter/highlighter_state.dart';
import 'package:quran/repositories/highlights_repository.dart';

class HighlightController extends StateNotifier<HighlighterState> {
  final Ref ref;

  HighlightController(this.ref) : super(HighlighterState.initial()) {
    _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    try {
      await HighlightsRepository.init();
      logger.info('Highlights repository initialized successfully');
    } catch (e, st) {
      logger.error('Failed to initialize highlights repository: $e\n$st');
      state = state.copyWith(error: 'Failed to initialize highlights: $e');
    }
  }

  // Create a new highlight
  Future<SavedHighlight?> createHighlight({
    required int page,
    required String location,
    Color? color,
    bool isPartial = false,
    double? startPercentage,
    double? endPercentage,
    String? note,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Use provided color or get from color picker
      final highlightColor = color ?? ref.read(selectedColorProvider);

      final highlight = SavedHighlight.fromColor(
        page: page,
        location: location,
        color: highlightColor ?? Colors.yellow,
        isPartial: isPartial,
        startPercentage: startPercentage,
        endPercentage: endPercentage,
        note: note,
      );

      // Save to database
      final savedHighlight = await HighlightsRepository.createHighlight(highlight);

      // Update state
      _addHighlightToState(savedHighlight);

      state = state.copyWith(isLoading: false);
      logger.info('Highlight created: ${savedHighlight.id}');
      
      return savedHighlight;
    } catch (e, st) {
      logger.error('Failed to create highlight: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create highlight: $e',
      );
      return null;
    }
  }

  // Create multiple highlights at once (for ayah highlighting without animation)
  Future<List<SavedHighlight>> createHighlights({
    required List<(int page, String location)> locations,
    Color? color,
    bool isPartial = false,
    double? startPercentage,
    double? endPercentage,
    String? note,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Use provided color or get from color picker
      final highlightColor = color ?? ref.read(selectedColorProvider);

      final highlights = <SavedHighlight>[];
      
      // Create all highlights
      for (final (page, location) in locations) {
        final highlight = SavedHighlight.fromColor(
          page: page,
          location: location,
          color: highlightColor ?? Colors.yellow,
          isPartial: isPartial,
          startPercentage: startPercentage,
          endPercentage: endPercentage,
          note: note,
        );
        highlights.add(highlight);
      }

      // Save all to database
      final savedHighlights = <SavedHighlight>[];
      for (final highlight in highlights) {
        final savedHighlight = await HighlightsRepository.createHighlight(highlight);
        savedHighlights.add(savedHighlight);
      }

      // Update state with all highlights at once
      for (final highlight in savedHighlights) {
        _addHighlightToState(highlight);
      }

      state = state.copyWith(isLoading: false);
      logger.info('Created ${savedHighlights.length} highlights');
      
      return savedHighlights;
    } catch (e, st) {
      logger.error('Failed to create highlights: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create highlights: $e',
      );
      return [];
    }
  }

  // Delete a highlight by ID
  Future<bool> deleteHighlight(String highlightId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Delete from database
      await HighlightsRepository.deleteHighlight(highlightId);

      // Update state
      _removeHighlightFromState(highlightId);

      state = state.copyWith(isLoading: false);
      logger.info('Highlight deleted: $highlightId');
      
      return true;
    } catch (e, st) {
      logger.error('Failed to delete highlight: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete highlight: $e',
      );
      return false;
    }
  }

  // Delete all highlights at a specific location
  Future<bool> deleteHighlightsAtLocation(int page, String location) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get highlights at this location
      final highlightsToDelete = state.getHighlightsForLocation(page, location);
      
      if (highlightsToDelete.isEmpty) {
        state = state.copyWith(isLoading: false);
        return true;
      }

      // Delete from database
      await HighlightsRepository.deleteHighlightsForLocation(page, location);

      // Update state
      for (final highlight in highlightsToDelete) {
        _removeHighlightFromState(highlight.id);
      }

      state = state.copyWith(isLoading: false);
      logger.info('Deleted ${highlightsToDelete.length} highlights at $page:$location');
      
      return true;
    } catch (e, st) {
      logger.error('Failed to delete highlights at location: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete highlights: $e',
      );
      return false;
    }
  }

  // Delete highlights at multiple locations at once (for ayah unhighlighting without animation)
  Future<bool> deleteHighlightsAtLocations(List<(int page, String location)> locations) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get all highlights to delete
      final allHighlightsToDelete = <SavedHighlight>[];
      for (final (page, location) in locations) {
        final highlightsAtLocation = state.getHighlightsForLocation(page, location);
        allHighlightsToDelete.addAll(highlightsAtLocation);
      }
      
      if (allHighlightsToDelete.isEmpty) {
        state = state.copyWith(isLoading: false);
        return true;
      }

      // Delete from database
      for (final (page, location) in locations) {
        await HighlightsRepository.deleteHighlightsForLocation(page, location);
      }

      // Update state - remove all highlights at once
      for (final highlight in allHighlightsToDelete) {
        _removeHighlightFromState(highlight.id);
      }

      state = state.copyWith(isLoading: false);
      logger.info('Deleted ${allHighlightsToDelete.length} highlights at ${locations.length} locations');
      
      return true;
    } catch (e, st) {
      logger.error('Failed to delete highlights at locations: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete highlights: $e',
      );
      return false;
    }
  }

  // Delete multiple highlights by IDs at once (without animation)
  Future<bool> deleteHighlightsByIds(List<String> highlightIds) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      if (highlightIds.isEmpty) {
        state = state.copyWith(isLoading: false);
        return true;
      }

      // Delete from database
      for (final id in highlightIds) {
        await HighlightsRepository.deleteHighlight(id);
      }

      // Update state - remove all highlights at once
      final updatedPageHighlights = Map<int, List<SavedHighlight>>.from(state.pageHighlights);
      final updatedHighlightById = Map<String, SavedHighlight>.from(state.highlightById);

      for (final id in highlightIds) {
        final highlight = updatedHighlightById[id];
        if (highlight != null) {
          // Remove from page highlights
          final pageHighlightsList = updatedPageHighlights[highlight.page];
          if (pageHighlightsList != null) {
            pageHighlightsList.removeWhere((h) => h.id == id);
            if (pageHighlightsList.isEmpty) {
              updatedPageHighlights.remove(highlight.page);
            }
          }
          // Remove from highlight by ID
          updatedHighlightById.remove(id);
        }
      }

      state = state.copyWith(
        pageHighlights: updatedPageHighlights,
        highlightById: updatedHighlightById,
        isLoading: false,
      );

      logger.info('Deleted ${highlightIds.length} highlights by IDs');
      
      return true;
    } catch (e, st) {
      logger.error('Failed to delete highlights by IDs: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete highlights: $e',
      );
      return false;
    }
  }

  // Load highlights for a specific page
  Future<void> loadHighlightsForPage(int page) async {
    try {
      // Don't set loading if we already have highlights for this page
      if (!state.pageHighlights.containsKey(page)) {
        state = state.copyWith(isLoading: true, error: null);
      }

      final highlights = await HighlightsRepository.getHighlightsForPage(page);

      // Update state
      final updatedPageHighlights = Map<int, List<SavedHighlight>>.from(state.pageHighlights);
      final updatedHighlightById = Map<String, SavedHighlight>.from(state.highlightById);

      updatedPageHighlights[page] = highlights;
      for (final highlight in highlights) {
        updatedHighlightById[highlight.id] = highlight;
      }

      state = state.copyWith(
        pageHighlights: updatedPageHighlights,
        highlightById: updatedHighlightById,
        isLoading: false,
      );

      logger.info('Loaded ${highlights.length} highlights for page $page');
    } catch (e, st) {
      logger.error('Failed to load highlights for page $page: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load highlights: $e',
      );
    }
  }

  // Load highlights for multiple pages
  Future<void> loadHighlightsForPages(List<int> pages) async {
    if (pages.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final highlights = await HighlightsRepository.getHighlightsForPages(pages);

      // Group highlights by page
      final Map<int, List<SavedHighlight>> groupedHighlights = {};
      for (final page in pages) {
        groupedHighlights[page] = [];
      }

      for (final highlight in highlights) {
        groupedHighlights[highlight.page]?.add(highlight);
      }

      // Update state
      final updatedPageHighlights = Map<int, List<SavedHighlight>>.from(state.pageHighlights);
      final updatedHighlightById = Map<String, SavedHighlight>.from(state.highlightById);

      for (final entry in groupedHighlights.entries) {
        updatedPageHighlights[entry.key] = entry.value;
        for (final highlight in entry.value) {
          updatedHighlightById[highlight.id] = highlight;
        }
      }

      state = state.copyWith(
        pageHighlights: updatedPageHighlights,
        highlightById: updatedHighlightById,
        isLoading: false,
      );

      logger.info('Loaded ${highlights.length} highlights for ${pages.length} pages');
    } catch (e, st) {
      logger.error('Failed to load highlights for pages: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load highlights: $e',
      );
    }
  }

  // Add partial highlight
  Future<SavedHighlight?> addPartialHighlight({
    required int page,
    required String location,
    required double startPercentage,
    required double endPercentage,
    Color? color,
    String? note,
  }) async {
    return createHighlight(
      page: page,
      location: location,
      color: color,
      isPartial: true,
      startPercentage: startPercentage,
      endPercentage: endPercentage,
      note: note,
    );
  }

  // Helper method to add highlight to state
  void _addHighlightToState(SavedHighlight highlight) {
    final updatedPageHighlights = Map<int, List<SavedHighlight>>.from(state.pageHighlights);
    final updatedHighlightById = Map<String, SavedHighlight>.from(state.highlightById);

    // Add to page highlights
    if (!updatedPageHighlights.containsKey(highlight.page)) {
      updatedPageHighlights[highlight.page] = [];
    }
    updatedPageHighlights[highlight.page]!.add(highlight);

    // Add to highlight by ID
    updatedHighlightById[highlight.id] = highlight;

    state = state.copyWith(
      pageHighlights: updatedPageHighlights,
      highlightById: updatedHighlightById,
    );
  }

  // Helper method to remove highlight from state
  void _removeHighlightFromState(String highlightId) {
    final highlight = state.highlightById[highlightId];
    if (highlight == null) return;

    final updatedPageHighlights = Map<int, List<SavedHighlight>>.from(state.pageHighlights);
    final updatedHighlightById = Map<String, SavedHighlight>.from(state.highlightById);

    // Remove from page highlights
    final pageHighlightsList = updatedPageHighlights[highlight.page];
    if (pageHighlightsList != null) {
      pageHighlightsList.removeWhere((h) => h.id == highlightId);
      if (pageHighlightsList.isEmpty) {
        updatedPageHighlights.remove(highlight.page);
      }
    }

    // Remove from highlight by ID
    updatedHighlightById.remove(highlightId);

    state = state.copyWith(
      pageHighlights: updatedPageHighlights,
      highlightById: updatedHighlightById,
    );
  }

  // Clear all highlights (for testing/reset)
  Future<void> clearAllHighlights() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await HighlightsRepository.deleteAllHighlights();

      state = HighlighterState.initial();
      logger.info('All highlights cleared');
    } catch (e, st) {
      logger.error('Failed to clear all highlights: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to clear highlights: $e',
      );
    }
  }
}