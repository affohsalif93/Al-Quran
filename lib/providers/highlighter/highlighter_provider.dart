import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/highlighter/word_highlight.dart';

final pageHighlightsProvider =
  StateProvider<Map<int, List<WordHighlight>>>(
    (ref) => {},
  );
