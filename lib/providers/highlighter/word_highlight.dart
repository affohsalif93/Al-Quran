import 'package:flutter/animation.dart';

class WordHighlight {
  final String location; // e.g. "2:255:5"
  final Color color;

  WordHighlight({
    required this.location,
    required this.color,
  });
}
