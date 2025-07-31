import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/views/drawers/select_mushaf/select_mushaf.dart';
import 'package:quran/views/footer/page_navigation.dart';
import 'package:quran/views/footer/page_view_mode.dart';
import 'package:quran/views/widgets/animated_show_hide.dart';
import 'package:quran/views/widgets/menu_wrapper.dart';

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PageViewMode(),
            PageNavigation(),
            SelectMushaf(),
          ],
        ),
      ),
    );
  }
}
