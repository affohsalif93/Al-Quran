import 'package:flutter/material.dart';

class ClipDiamond extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;
    Path path =
    Path()
      ..moveTo(0, height * 0.5)
      ..lineTo(width * 0.5, 0)
      ..lineTo(width, height * 0.5)
      ..lineTo(width * 0.5, height);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
