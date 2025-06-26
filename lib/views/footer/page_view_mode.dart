import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/providers/home/home_controller.dart';
import 'package:quran/providers/home/home_state.dart';

class PageViewMode extends ConsumerWidget {
  const PageViewMode({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final homeActions = ref.read(homeControllerProvider.notifier);

    return CustomSlidingSegmentedControl<int>(
      initialValue: homeState.isBookView ? 1 : 2,
      isShowDivider: true,
      isDisabled: !homeState.isViewerToggleEnabled,
      children: {
        1: Icon(
          CupertinoIcons.book_fill,
          size: 18.spMin,
          color: Colors.black,
        ),
        2: Icon(
          CupertinoIcons.rectangle_expand_vertical,
          size: 18.spMin,
          color: Colors.black,
        ),
      },
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: 25,
      height: 30,
      thumbDecoration: BoxDecoration(
        color: Colors.lightGreen,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.green,
          width: 1.5,
        ),
      ),
      onValueChanged: (value) {
        homeActions.setViewMode(value == 1 ? ViewerMode.double : ViewerMode.single);
      },
    );
  }
}
