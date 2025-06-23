import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/pages/home/home_controller.dart';
import 'package:quran/pages/home/widgets/animated_show_hide.dart';
import 'package:quran/pages/home/widgets/bottom_bar/page_navigation.dart';
import 'package:quran/pages/home/widgets/bottom_bar/page_view_mode.dart';
import 'package:quran/pages/home/widgets/menu_wrapper.dart';
import 'package:quran/pages/home/widgets/select_mushaf/select_mushaf.dart';

class BottomBar extends ConsumerWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuWrapper(
      height: 50,
      direction: AnimationDirection.appearFromBottom,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          children: [
            PageViewMode(),
            Expanded(
              child: PageNavigation(),
            ),
            SelectMushaf(),
          ],
        ),
      ),
    );
  }
}
