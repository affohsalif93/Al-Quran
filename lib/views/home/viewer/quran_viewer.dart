import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/core/utils/logger.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        final pageDimensions = getPageDimensions(
          availableHeight: availableHeight,
          availableWidth: availableWidth,
          pageAspectRatio: 0.9 / 1.41,
          contentAspectRatio: 1 / 1.41,
        );

        return FutureBuilder<List<Widget>>(
          future: Future.wait([
            pageWidgetBuilder.buildPageContent(
              pageNumber: index + 1,
              width: pageDimensions.contentWidth,
              height: pageDimensions.contentHeight,
            ),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final contents = snapshot.data!;
            return QuranPage(
              width: pageDimensions.pageWidth,
              height: pageDimensions.pageHeight,
              pageNumber: index + 1,
              content: contents.first,
            );
          },
        );
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        final pageDimensions = getPageDimensions(
          availableHeight: availableHeight,
          availableWidth: availableWidth,
          pageAspectRatio: 0.9 / 1.41,
          contentAspectRatio: 1 / 1.41,
        );

        return FutureBuilder<List<Widget>>(
          future: Future.wait([
            pageContentBuilder.buildPageContent(
              pageNumber: index + 2,
              width: pageDimensions.contentWidth,
              height: pageDimensions.contentHeight,
            ),
            pageContentBuilder.buildPageContent(
              pageNumber: index + 1,
              width: pageDimensions.contentWidth,
              height: pageDimensions.contentHeight,
            ),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final widgets = snapshot.data!;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QuranPage(
                  content: widgets[0],
                  width: pageDimensions.pageWidth,
                  height: pageDimensions.pageHeight,
                  pageNumber: index + 2,
                ),
                QuranPage(
                  content: widgets[1],
                  width: pageDimensions.pageWidth,
                  height: pageDimensions.pageHeight,
                  pageNumber: index + 1,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class PageDimensions {
  final double pageWidth;
  final double pageHeight;
  final double contentWidth;
  final double contentHeight;

  PageDimensions({
    required this.pageWidth,
    required this.pageHeight,
    required this.contentWidth,
    required this.contentHeight,
  });
}

PageDimensions getPageDimensions({
  required double availableHeight,
  required double availableWidth,
  required double pageAspectRatio,
  required double contentAspectRatio,
}) {
  // First fit the page within available space preserving page aspect ratio
  double pageWidth = availableWidth;
  double pageHeight = pageWidth / pageAspectRatio;

  if (pageHeight > availableHeight) {
    pageHeight = availableHeight;
    pageWidth = pageHeight * pageAspectRatio;
  }

  // Now fit the content inside the page preserving content aspect ratio
  double contentWidth = pageWidth;
  double contentHeight = contentWidth / contentAspectRatio;

  if (contentHeight > pageHeight) {
    contentHeight = pageHeight;
    contentWidth = contentHeight * contentAspectRatio;
  }

  return PageDimensions(
    pageWidth: pageWidth,
    pageHeight: pageHeight,
    contentWidth: contentWidth,
    contentHeight: contentHeight,
  );
}

