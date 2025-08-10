import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/global/global_controller.dart';

class ZoomControl extends ConsumerWidget {
  const ZoomControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalControllerProvider);
    final globalController = ref.read(globalControllerProvider.notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => globalController.zoomOut(),
          icon: const Icon(Icons.zoom_out),
          iconSize: 22,
          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
        ),
        SizedBox(
          width: 140,
          child: Slider(
            value: globalState.zoomLevel,
            min: 0.5,
            max: 1.0,
            divisions: 100,
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Colors.grey,
            onChanged: (value) {
              globalController.setZoomLevel(value);
            },
          ),
        ),
        IconButton(
          onPressed: () => globalController.zoomIn(),
          icon: const Icon(Icons.zoom_in),
          iconSize: 22,
          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
        ),
        TextButton(
          onPressed: () => globalController.resetZoom(),
          child: Text(
            '${(globalState.zoomLevel * 100).round()}%',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}