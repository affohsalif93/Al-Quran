import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/views/home/viewer/page_content_builder.dart';

class DoublePageViewer extends ConsumerWidget {
  final int index;

  const DoublePageViewer({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageContentBuilder = PageContentBuilder(ref);

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
            aspectRatio: 2 / 1.41,
            child: Row(
              spacing: 0,
              children: [
                BookPage(
                  widget: widgets[0],
                  side: "left",
                  pageNumber: index + 2,
                ),
                BookPage(
                  widget: widgets[1],
                  side: "right",
                  pageNumber: index + 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BookPage extends StatelessWidget {
  const BookPage({
    super.key,
    required this.widget,
    required this.pageNumber,
    this.side = "left",
  });

  final Widget widget;
  final String side;
  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F5EE),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius:
              side == "left"
                  ? const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  )
                  : const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
          gradient: LinearGradient(
            begin:
                side == "left" ? Alignment.centerRight : Alignment.centerLeft,
            end: side == "left" ? Alignment.centerLeft : Alignment.centerRight,
            colors: [const Color(0x33E1DCDC), const Color(0xFFF6F5EE)],
            stops: const [0.0, 0.02],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 38),
            Expanded(child: AspectRatio(aspectRatio: 1 / 1.41, child: widget)),
            const SizedBox(height: 8),
            Text(
              "$pageNumber",
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
