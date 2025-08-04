import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/color_picker/color_picker_provider.dart';

class ColorPickerView extends ConsumerWidget {
  const ColorPickerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorPickerState = ref.watch(colorPickerProvider);
    final colorPickerNotifier = ref.read(colorPickerProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top section - Color preview and predefined colors
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Selected color preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorPickerState.selectedColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'Selected Color',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _getContrastColor(colorPickerState.selectedColor),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Predefined colors section
              Text(
                'Choose Color:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Predefined colors grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1,
                ),
                itemCount: colorPickerState.predefinedColors.length,
                itemBuilder: (context, index) {
                  final color = colorPickerState.predefinedColors[index];
                  final isSelected = color == colorPickerState.selectedColor;

                  return GestureDetector(
                    onTap: () => colorPickerNotifier.selectColor(color),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey.shade300,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: _getContrastColor(color),
                              size: 20,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
          
          // Spacer to push custom color button to bottom
          const Expanded(child: SizedBox()),
          
          // Bottom section - Custom color button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCustomColorPicker(context, ref),
              icon: const Icon(Icons.palette, size: 18),
              label: const Text(
                'Custom Color',
                style: TextStyle(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    // Calculate luminance to determine if we should use light or dark text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  void _showCustomColorPicker(BuildContext context, WidgetRef ref) {
    Color tempColor = ref.read(colorPickerProvider).selectedColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Custom Color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: tempColor,
            onColorChanged: (color) {
              tempColor = color.withOpacity(0.4); // Ensure transparency for highlights
            },
            availableColors: [
              Colors.red,
              Colors.pink,
              Colors.purple,
              Colors.deepPurple,
              Colors.indigo,
              Colors.blue,
              Colors.lightBlue,
              Colors.cyan,
              Colors.teal,
              Colors.green,
              Colors.lightGreen,
              Colors.lime,
              Colors.yellow,
              Colors.amber,
              Colors.orange,
              Colors.deepOrange,
              Colors.brown,
              Colors.grey,
              Colors.blueGrey,
            ].map((color) => color.withOpacity(0.4)).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(colorPickerProvider.notifier).addCustomColor(tempColor);
              Navigator.of(context).pop();
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }
}

// Simple block color picker
class BlockPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final List<Color> availableColors;

  const BlockPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
    required this.availableColors,
  });

  @override
  State<BlockPicker> createState() => _BlockPickerState();
}

class _BlockPickerState extends State<BlockPicker> {
  Color? selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.pickerColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 150,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: widget.availableColors.length,
        itemBuilder: (context, index) {
          final color = widget.availableColors[index];
          final isSelected = color == selectedColor;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedColor = color;
              });
              widget.onColorChanged(color);
            },
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey.shade400,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}