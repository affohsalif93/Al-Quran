import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/providers/global/global_state.dart';

class PageViewMode extends ConsumerWidget {
  const PageViewMode({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalControllerProvider);
    final homeActions = ref.read(globalControllerProvider.notifier);

    return CustomSlidingSegmentedControl<int>(
      initialValue: globalState.isBookView ? 1 : 2,
      isShowDivider: true,
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
      padding: 20,
      height: 30,
      thumbDecoration: BoxDecoration(
        color: Colors.lightGreen,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1.5,
        ),
      ),
      onValueChanged: (value) {
        homeActions.setViewMode(value == 1 ? ViewMode.double : ViewMode.single);
      },
    );
  }
}
