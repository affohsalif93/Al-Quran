import 'package:flutter/material.dart';

class QuranPage extends StatelessWidget {
  final Widget widget;
  late final String side;
  final int pageNumber;

  QuranPage({super.key, required this.widget, required this.pageNumber}) {
    side = pageNumber.isEven ? "left" : "right";
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
            begin: side == "left" ? Alignment.centerRight : Alignment.centerLeft,
            end: side == "left" ? Alignment.centerLeft : Alignment.centerRight,
            colors: [const Color(0x33E1DCDC), const Color(0xFFF6F5EE)],
            stops: const [0.0, 0.01],
            tileMode: TileMode.clamp,
          ),
        ),
        child: AspectRatio(aspectRatio: 0.9 / 1.41, child: widget),
      ),
    );
  }
}
