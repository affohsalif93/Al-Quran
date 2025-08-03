import 'package:flutter/material.dart';
import 'package:quran/core/extensions/context_extensions.dart';

class QuranPage extends StatelessWidget {
  final Widget content;
  late final String side;
  final int pageNumber;
  final double width;
  final double height;

  QuranPage({
    super.key,
    required this.content,
    required this.pageNumber,
    required this.width,
    required this.height,
  }) {
    side = pageNumber.isEven ? "left" : "right";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: context.colors.quranPageBackground,
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
      ),
      child: content,
    );
  }
}
