import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/providers/home/home_controller.dart';

class PageViewer extends ConsumerWidget {
  const PageViewer({super.key});

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
              homeState.isBookView
                  ? BookViewPage(index: index)
                  : SinglePageViewer(index: index),
        );
      },
    );
  }
}

class SinglePageViewer extends ConsumerWidget {
  final int index;

  const SinglePageViewer({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeController = ref.read(homeControllerProvider.notifier);

    return FutureBuilder<List<Widget>>(
      future: Future.wait([homeController.getPageWidget(index + 1, ref)]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final widgets = snapshot.data!;

        return Center(
          child: AspectRatio(
            aspectRatio: 1 / 1.41,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: widgets[0],
            ),
          ),
        );
      },
    );
  }
}

class BookViewPage extends ConsumerWidget {
  final int index;

  const BookViewPage({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeController = ref.read(homeControllerProvider.notifier);

    final future1 = homeController.getPageWidget(index + 2, ref);
    final future2 = homeController.getPageWidget(index + 1, ref);

    return FutureBuilder<List<Widget>>(
      future: Future.wait([future1, future2]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final widgets = snapshot.data!;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [widgets[0], const SizedBox(width: 5), widgets[1]],
        );
      },
    );
  }
}
