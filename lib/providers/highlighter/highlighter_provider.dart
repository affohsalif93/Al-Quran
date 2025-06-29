import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/highlighter/highlight_controller.dart';
import 'package:quran/providers/highlighter/highlighter_state.dart';

final highlightControllerProvider =
    StateNotifierProvider<HighlightController, HighlighterState>((ref) {
      return HighlightController(ref);
    });

