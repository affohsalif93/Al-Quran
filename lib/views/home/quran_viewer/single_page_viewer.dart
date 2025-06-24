import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/views/home/quran_viewer/page_content_builder.dart';

class SinglePageViewer extends ConsumerWidget {
  final int index;

  const SinglePageViewer({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageWidgetBuilder = PageContentBuilder(ref);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return FutureBuilder<List<Widget>>(
      future: Future.wait([
        pageWidgetBuilder.buildPageContent(index + 1, width, height),
      ]),
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
                color: const Color(0xFFF6F5EE),
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
