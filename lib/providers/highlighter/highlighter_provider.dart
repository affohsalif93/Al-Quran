import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/highlighter/highlight_controller.dart';
import 'package:quran/providers/highlighter/word_highlight.dart';

final highlightControllerProvider =
    NotifierProvider<HighlightController, Map<int, List<WordHighlight>>>(
      () => HighlightController(),
    );
