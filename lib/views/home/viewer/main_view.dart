import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/views/home/viewer/notes_view.dart';
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
                dividerBuilder:
                    (axis, index, resizable, dragging, highlighted, themeData) =>
                        Container(color: context.colors.navBarBackground, width: 10),

                initialAreas: [
                  Area(flex: 7, min: 5, builder: (context, area) => QuranViewer()),
                  Area(flex: 3, min: 2, builder: (context, area) => RightView()),
                ],
              )
              : QuranViewer(),
    );
  }
}

class RightView extends ConsumerWidget {
  const RightView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalControllerProvider);
    final globalController = ref.read(globalControllerProvider.notifier);

    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: NotesView(),
    );
  }
}
