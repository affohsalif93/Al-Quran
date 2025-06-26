import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/highlighter/highlight_controller.dart';

final highlightControllerProvider =
    StateNotifierProvider<HighlightController, HighlighterState>((ref) {
      return HighlightController(ref);
    });

