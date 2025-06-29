import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quran/providers/drawer/drawer_provider.dart';
import 'package:quran/providers/drawer/drawer_state.dart';
import 'package:quran/providers/home/home_controller.dart';
import 'package:quran/views/widgets/animated_show_hide.dart';
import 'package:quran/views/widgets/menu_wrapper.dart';

class TopMenuBar extends ConsumerWidget {
  const TopMenuBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerActions = ref.watch(drawerControllerProvider.notifier);
    final homeController = ref.watch(homeControllerProvider.notifier);

    return MenuWrapper(
      direction: AnimationDirection.appearFromTop,
      height: 40,
      child: Row(
        children: [
          TextButton.icon(
            icon: Icon(
              Symbols.menu_book,
              size: 18.spMin,
              color: Colors.green,
            ),
            label: const Text("Surahs"),
            onPressed: () {
              drawerActions.toggleLeftDrawer(DrawerComponentKey.surahs);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: CustomSlidingSegmentedControl<int>(
                initialValue: homeController.getCurrentTabIndex(),
                children: {
                  1: Text('Mushaf', style: TextStyle(fontWeight: FontWeight.w500)),
                  2: Text('Tafsir', style: TextStyle(fontWeight: FontWeight.w500)),
                  3: Text('Hifz', style: TextStyle(fontWeight: FontWeight.w500)),
                  4: Text('Notes', style: TextStyle(fontWeight: FontWeight.w500)),
                },
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: 30,
                height: 35,
                thumbDecoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                ),
                duration: Duration(milliseconds: 100),
                curve: Curves.easeInToLinear,
                onValueChanged: (v) {
                  homeController.setCurrentTabByIndex(v);
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
