import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../home_controller.dart';
import 'animated_show_hide.dart';

class MenuWrapper extends ConsumerWidget {
  const MenuWrapper({
    super.key,
    required this.child,
    required this.direction,
    this.height = 40
  });

  final Widget child;
  final AnimationDirection direction;
  final double height;
  // margin



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShow =
        ref.watch(homeControllerProvider.select((c) => c.isShowMenu));
    return AnimatedShowHide(
      direction: direction,
      isShow: isShow,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        height: height,
        decoration: BoxDecoration(
          color: const Color.fromARGB(206, 226, 220, 220),
          // borderRadius: BorderRadius.circular(8.r),

          // color: context.isDark
          //     ? const Color.fromARGB(140, 233, 225, 225)
          //     : Colors.transparent,
          // width: 1.r,
          // border: Border(
          //   bottom: BorderSide(
          //     color: Colors.grey,
          //     width: 1,
          //   ),
          // ),
        ),
        child: child,
      ),
    );
  }
}
