import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/views/home/viewer/quran_page.dart';
import 'package:quran/views/home/viewer/quran_page_content_builder.dart';

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
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(color: Colors.white),
          child: Center(child: PageViewer(index: index + 1)),
        );
      },
    );
  }
}

class PageViewer extends ConsumerWidget {
  final int index;

  const PageViewer({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalControllerProvider);
    final pageContentBuilder = QuranPageContentBuilder(ref);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        final dims = getPageDimensions(
          availableHeight: availableHeight,
          availableWidth: availableWidth,
          pageAspectRatio: 0.9 / 1.41,
          contentAspectRatio: 1 / 1.41,
        );

        return FutureBuilder<List<Widget>>(
          future: Future.wait([
            pageContentBuilder.buildPageContent(
              pageNumber: index,
              width: dims.contentWidth,
              height: dims.contentHeight,
            ),
            pageContentBuilder.buildPageContent(
              pageNumber: index + 1,
              width: dims.contentWidth,
              height: dims.contentHeight,
            ),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final contents = snapshot.data!;

            if (globalState.isBookView) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QuranPage(
                    content: contents[1],
                    width: dims.pageWidth,
                    height: dims.pageHeight,
                    pageNumber: index + 1,
                  ),
                  QuranPage(
                    content: contents[0],
                    width: dims.pageWidth,
                    height: dims.pageHeight,
                    pageNumber: index,
                  ),
                ],
              );
            } else {
              return QuranPage(
                content: contents[0],
                width: dims.pageWidth,
                height: dims.pageHeight,
                pageNumber: index,
              );
            }
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
