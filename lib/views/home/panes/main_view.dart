import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/views/home/panes/right_view.dart';
import 'package:quran/views/home/panes/left_view.dart';
import 'package:quran/views/home/viewer/quran_viewer.dart';

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalControllerProvider);
    final globalController = ref.read(globalControllerProvider.notifier);

    return Container(
      child:
          globalState.isSplitViewer
              ? MultiSplitView(
                initialAreas: [
                  Area(flex: 5, min: 4, builder: (context, area) => LeftView()),
                  Area(flex: 5, min: 4, builder: (context, area) => RightView()),
                ],
              )
              : QuranViewer(),
    );
  }
}
