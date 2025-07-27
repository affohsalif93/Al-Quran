import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/views/home/viewer/quran_page.dart';
import 'package:quran/views/home/viewer/quran_page_builder.dart';

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
          ),
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
    final pageWidgetBuilder = QuranPageBuilder(ref);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return FutureBuilder<List<Widget>>(
      future: Future.wait([pageWidgetBuilder.buildPageContent(index + 1, width, height)]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final contents = snapshot.data!;
        return QuranPage(pageNumber: index + 1, widget: contents.first);
      },
    );
  }
}

class DoublePageViewer extends ConsumerWidget {
  final int index;

  const DoublePageViewer({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageContentBuilder = QuranPageBuilder(ref);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return FutureBuilder<List<Widget>>(
      future: Future.wait([
        pageContentBuilder.buildPageContent(index + 2, width / 2, height),
        pageContentBuilder.buildPageContent(index + 1, width / 2, height),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final widgets = snapshot.data!;

        return Center(
          child: AspectRatio(
            aspectRatio: 1.9 / 1.41,
            child: Row(
              children: [
                QuranPage(widget: widgets[0], pageNumber: index + 2),
                QuranPage(widget: widgets[1], pageNumber: index + 1),
              ],
            ),
          ),
        );
      },
    );
  }
}
