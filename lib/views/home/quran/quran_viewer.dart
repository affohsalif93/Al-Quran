import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/views/home/quran/quran_page.dart';
import 'package:quran/views/home/quran/quran_page_content_builder.dart';

class QuranViewer extends ConsumerStatefulWidget {
  const QuranViewer({super.key});

  @override
  ConsumerState<QuranViewer> createState() => _QuranViewerState();
}

class _QuranViewerState extends ConsumerState<QuranViewer> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalState = ref.watch(globalControllerProvider);
    final globalController = ref.read(globalControllerProvider.notifier);

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              globalController.goToNextPage();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              globalController.goToPreviousPage();
            }
          }
        },
        child: Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              final delta = event.scrollDelta.dy;
              if (delta > 0) {
                globalController.zoomOut();
              } else if (delta < 0) {
                globalController.zoomIn();
              }
            }
          },
          child: ClipRect(
            child: Transform.scale(
              scale: globalState.zoomLevel,
              alignment: Alignment.center,
              child: PageView.builder(
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
                    child: Center(child: PageViewer(page: index + 1)),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PageViewer extends ConsumerWidget {
  final int page;

  const PageViewer({super.key, required this.page});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalControllerProvider);
    final pageContentBuilder = QuranPageContentBuilder(ref);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the actual bounded constraints instead of maxWidth/maxHeight
        // This ensures we work within the actual container area
        final availableWidth = constraints.hasBoundedWidth ? constraints.maxWidth : constraints.biggest.width;
        final availableHeight = constraints.hasBoundedHeight ? constraints.maxHeight : constraints.biggest.height;

        final dims = getPageDimensions(
          availableHeight: availableHeight,
          availableWidth: availableWidth,
          pageAspectRatio: 0.95 / 1.41,
          contentAspectRatio: 1 / 1.41,
        );

        return FutureBuilder<List<Widget>>(
          future: Future.wait([
            pageContentBuilder.buildPageContent(
              page: page,
              width: dims.contentWidth,
              height: dims.contentHeight,
            ),
            pageContentBuilder.buildPageContent(
              page: page + 1,
              width: dims.contentWidth,
              height: dims.contentHeight,
            ),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final contents = snapshot.data!;

            Widget pageContent;
            if (globalState.isBookView) {
              pageContent = Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QuranPage(
                    content: contents[1],
                    width: dims.pageWidth,
                    height: dims.pageHeight,
                    pageNumber: page + 1,
                  ),
                  QuranPage(
                    content: contents[0],
                    width: dims.pageWidth,
                    height: dims.pageHeight,
                    pageNumber: page,
                  ),
                ],
              );
            } else {
              pageContent = QuranPage(
                content: contents[0],
                width: dims.pageWidth,
                height: dims.pageHeight,
                pageNumber: page,
              );
            }

            // Wrap in a sized container to prevent overflow
            return SizedBox(
              width: availableWidth,
              height: availableHeight,
              child: FittedBox(
                fit: BoxFit.contain,
                child: pageContent,
              ),
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
  // Add some padding to prevent overflow
  const double padding = 20.0;
  final constrainedWidth = max(0.0, availableWidth - padding);
  final constrainedHeight = max(0.0, availableHeight - padding);
  
  // First fit the page within available space preserving page aspect ratio
  double pageWidth = constrainedWidth;
  double pageHeight = pageWidth / pageAspectRatio;

  if (pageHeight > constrainedHeight) {
    pageHeight = constrainedHeight;
    pageWidth = pageHeight * pageAspectRatio;
  }

  // Ensure we don't exceed the available space
  pageWidth = min(pageWidth, constrainedWidth);
  pageHeight = min(pageHeight, constrainedHeight);

  // Now fit the content inside the page preserving content aspect ratio
  double contentWidth = pageWidth * 0.95; // Leave some margin inside page
  double contentHeight = contentWidth / contentAspectRatio;

  if (contentHeight > pageHeight * 0.95) {
    contentHeight = pageHeight * 0.95;
    contentWidth = contentHeight * contentAspectRatio;
  }

  return PageDimensions(
    pageWidth: pageWidth,
    pageHeight: pageHeight,
    contentWidth: contentWidth,
    contentHeight: contentHeight,
  );
}
