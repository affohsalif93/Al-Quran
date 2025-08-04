import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/providers/global/global_state.dart';
import 'package:quran/views/home/highlights/color_picker_view.dart';
import 'package:quran/views/home/notes/notes_view.dart';
import 'package:quran/views/home/quran/quran_viewer.dart';

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalControllerProvider);

    // Create persistent QuranViewer that won't rebuild
    final quranViewer = QuranViewer();

    return Container(
      child:
          globalState.isSplitViewer
              ? MultiSplitView(
                key: ValueKey('split_${globalState.currentTab}'), // Only rebuild right panel
                dividerBuilder:
                    (axis, index, resizable, dragging, highlighted, themeData) =>
                        Container(color: context.colors.navBarBackground, width: 10),
                initialAreas: [
                  Area(flex: 8, min: 7, builder: (context, area) => quranViewer),
                  if (globalState.currentTab != HomeTab.mushaf)
                    _getAreasForTab(globalState.currentTab, quranViewer),
                ],
              )
              : quranViewer, // Same instance for non-split view
    );
  }

  Area _getAreasForTab(HomeTab currentTab, Widget quranViewer) {
    switch (currentTab) {
      case HomeTab.notes:
        return Area(
          flex: 2,
          min: 3,
          builder: (context, area) => Container(
            decoration: BoxDecoration(color: context.colors.quranPageBackground),
            child: const NotesView(),
          ),
        );

      case HomeTab.highlights:
        return Area(
          flex: 1,
          min: 1.5,
          max: 2,
          builder: (context, area) => Container(
            decoration: BoxDecoration(color: context.colors.quranPageBackground),
            child: const ColorPickerView(),
          ),
        );

      case HomeTab.tafsir:
        return Area(
          flex: 2,
          min: 3,
          builder: (context, area) => Container(
            decoration: BoxDecoration(color: context.colors.quranPageBackground),
            child: const Center(child: Text('Tafsir View Coming Soon')),
          ),
        );

      case HomeTab.mushaf:
      default:
        throw UnimplementedError('Tab $currentTab should not reach here - handled by conditional');
    }
  }
}
