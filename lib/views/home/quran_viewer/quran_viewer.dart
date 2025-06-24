import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/providers/home/home_controller.dart';
import 'package:quran/views/home/quran_viewer/double_page_viewer.dart';
import 'package:quran/views/home/quran_viewer/single_page_viewer.dart';

class QuranViewer extends ConsumerWidget {
  const QuranViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final homeController = ref.read(homeControllerProvider.notifier);
    final aspectRatioRange =
    homeState.isBookView ? (min: 0.96, max: 1.32) : (min: 1.0, max: 1.2);

    return PageView.builder(
      controller: homeController.pageController,
      reverse: context.isLtr,
      itemCount: homeController.getMushafPageCount(),
      onPageChanged: (index) {
        // homeController.setCurrentPage(index + 1);
      },
      itemBuilder: (context, index) {
        return Center(
          child:
          // homeState.isBookView
          //     ? BookViewPage(index: index)
          //     :
              SinglePageViewer(index: index)
        );
      },
    );
  }
}
