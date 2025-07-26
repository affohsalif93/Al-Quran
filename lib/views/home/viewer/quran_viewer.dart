import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/views/home/viewer/double_page_view.dart';
import 'package:quran/views/home/viewer/single_page_view.dart';

class QuranViewer extends ConsumerWidget {
  const QuranViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalControllerProvider);
    final globalController = ref.read(globalControllerProvider.notifier);

    return PageView.builder(
      controller: globalController.pageController,
      reverse: context.isLtr,
      itemCount: globalController.getMushafPageCount(),
      onPageChanged: (index) {
        // globalController.setCurrentPage(index + 1);
      },
      itemBuilder: (context, index) {
        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child:
              globalState.isBookView
                  ? DoublePageViewer(index: index)
                  : SinglePageViewer(index: index),
          )
        );
      },
    );
  }
}
