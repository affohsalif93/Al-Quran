import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quran/providers/drawer/drawer_provider.dart';
import 'package:quran/providers/drawer/drawer_state.dart';
import 'package:quran/views/widgets/animated_show_hide.dart';
import 'package:quran/views/widgets/menu_wrapper.dart';

class TopMenuBar extends ConsumerWidget {
  const TopMenuBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerActions = ref.watch(drawerControllerProvider.notifier);

    return MenuWrapper(
      direction: AnimationDirection.appearFromTop,
      child: Row(
        // textDirection: TextDirection.rtl,
        children: [
          TextButton.icon(
            icon: Icon(
              Symbols.menu_book,
              size: 18.spMin,
              color: Colors.green,
            ),
            label: const Text("Chapters"),
            onPressed: () {
              drawerActions.toggleLeftDrawer(DrawerComponentKey.chapters);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: CustomSlidingSegmentedControl<int>(
                initialValue: 2,
                isShowDivider: true,
                // isStretch: true,
                children: {
                  1: Text('Mushaf'),
                  2: Text('Tafsir'),
                  3: Text('Books'),
                },
                decoration: BoxDecoration(
                  // color: CupertinoColors.lightBackgroundGray,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: 30,
                height: 30,
                thumbDecoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withOpacity(.3),
                  //     blurRadius: 2.0,
                  //     spreadRadius: 0.5,
                  //     offset: Offset(
                  //       0.0,
                  //       1.0,
                  //     ),
                  //   ),
                  // ],
                ),
                duration: Duration(milliseconds: 100),
                curve: Curves.easeInToLinear,
                onValueChanged: (v) {
                  print(v);
                },
              ),
            ),
          ),
          TextButton.icon(
            icon: const Icon(
              Symbols.font_download,
              weight: 300,
            ),
            label: Text("Settings"),
            onPressed: () => drawerActions.toggleRightDrawer(DrawerComponentKey.settings),
          ),
        ],
      ),
    );
  }
}
