import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ColorPickerState {
  final Color selectedColor;
  final List<Color> predefinedColors;

  const ColorPickerState({
    required this.selectedColor,
    required this.predefinedColors,
  });

  ColorPickerState copyWith({
    Color? selectedColor,
    List<Color>? predefinedColors,
  }) {
    return ColorPickerState(
      selectedColor: selectedColor ?? this.selectedColor,
      predefinedColors: predefinedColors ?? this.predefinedColors,
    );
  }
}

class ColorPickerNotifier extends StateNotifier<ColorPickerState> {
  ColorPickerNotifier()
      : super(ColorPickerState(
          selectedColor: Colors.yellow.withOpacity(0.4),
          predefinedColors: [
            Colors.yellow.withOpacity(0.4),
            Colors.green.withOpacity(0.4),
            Colors.blue.withOpacity(0.4),
            Colors.orange.withOpacity(0.4),
            Colors.pink.withOpacity(0.4),
            Colors.purple.withOpacity(0.4),
            Colors.red.withOpacity(0.4),
            Colors.teal.withOpacity(0.4),
            Colors.cyan.withOpacity(0.4),
            Colors.indigo.withOpacity(0.4),
            Colors.lime.withOpacity(0.4),
            Colors.amber.withOpacity(0.4),
          ],
        ));

  void selectColor(Color color) {
    state = state.copyWith(selectedColor: color);
  }

  void addCustomColor(Color color) {
    final updatedColors = [...state.predefinedColors, color];
    state = state.copyWith(
      selectedColor: color,
      predefinedColors: updatedColors,
    );
  }
}

final colorPickerProvider = StateNotifierProvider<ColorPickerNotifier, ColorPickerState>((ref) {
  return ColorPickerNotifier();
});

// Convenience provider for just the selected color
final selectedColorProvider = Provider<Color>((ref) {
  return ref.watch(colorPickerProvider).selectedColor;
});