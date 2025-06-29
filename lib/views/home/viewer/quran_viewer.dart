import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/providers/home/home_controller.dart';
import 'package:quran/views/home/viewer/double_page_view.dart';
import 'package:quran/views/home/viewer/single_page_view.dart';

class QuranViewer extends ConsumerWidget {
  const QuranViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final homeController = ref.read(homeControllerProvider.notifier);

    return PageView.builder(
      controller: homeController.pageController,
      reverse: context.isLtr,
      itemCount: homeController.getMushafPageCount(),
      onPageChanged: (index) {
        // homeController.setCurrentPage(index + 1);
      },
      itemBuilder: (context, index) {
        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 30),
            child:
              homeState.isBookView
                  ? DoublePageViewer(index: index)
                  : SinglePageViewer(index: index),
          )
        );
      },
    );
  }
}
