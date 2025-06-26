import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/providers/home/home_controller.dart';
import 'package:quran/views/home/viewer/double_page_viewer.dart';
import 'package:quran/views/home/viewer/quran_viewer.dart';
import 'package:quran/views/home/viewer/single_page_viewer.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final homeController = ref.read(homeControllerProvider.notifier);

    return Container(
      child:
          homeState.isSplitViewer
              ? MultiSplitView(
                initialAreas: [
                  Area(flex: 5, min: 4, builder: (context, area) => QuranViewer()),
                  Area(flex: 5, min: 4, builder: (context, area) => Draft.yellow()),
                ],
              )
              : QuranViewer(),
    );
  }
}
