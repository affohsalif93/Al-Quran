import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/views/home/quran_viewer/page_content_builder.dart';

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
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1 / 1.41,
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 55,
                        bottom: 55,
                        left: 20,
                        right: 0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F5EE),
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        gradient: const LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            Color(0x33E1DCDC),
                            Color(0xFFF6F5EE),
                          ],
                          stops: [0.0, 0.02],
                          tileMode: TileMode.clamp,
                        ),
                      ),
                      child: widgets[0],
                    ),
                  ),
                ),

                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1 / 1.41,
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 55,
                        bottom: 55,
                        left: 0,
                        right: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F5EE),
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0x33E1DCDC),
                            Color(0xFFF6F5EE),
                          ],
                          stops: [0.0, 0.02],
                          tileMode: TileMode.clamp,
                        ),
                      ),
                      child: widgets[1],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
