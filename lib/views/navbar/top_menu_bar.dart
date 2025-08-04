import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quran/providers/drawer/drawer_provider.dart';
import 'package:quran/providers/drawer/drawer_state.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/providers/global/global_state.dart';
import 'package:quran/views/widgets/animated_show_hide.dart';
import 'package:quran/views/widgets/menu_wrapper.dart';

class TabItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const TabItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        spacing: 5,
        children: [
          Icon(icon, size: 20),
          Text(text, style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}

class TopMenuBar extends ConsumerWidget {
  const TopMenuBar({super.key});

  int _getSafeTabIndex(int tabIndex) {
    // Ensure tab index is within valid range for the slider
    if (tabIndex < 1 || tabIndex > 3) {
      return 1; // Default to Mushaf tab
    }
    return tabIndex;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerActions = ref.watch(drawerControllerProvider.notifier);
    final globalController = ref.watch(globalControllerProvider.notifier);

    return MenuWrapper(
      direction: AnimationDirection.appearFromTop,
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            icon: Icon(Symbols.menu_book, size: 24.spMin),
            // label: const Text("Surahs", style: TextStyle(fontWeight: FontWeight.w500)),
            label: const Text("Surahs"),
            onPressed: () {
              drawerActions.toggleLeftDrawer(DrawerComponentKey.surahs);
            },
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: CustomSlidingSegmentedControl<int>(
                initialValue: _getSafeTabIndex(globalController.getCurrentTabIndex()),
                children: {
                  1: TabItem(icon: CupertinoIcons.book_fill, text: 'Mushaf'),
                  2: TabItem(icon: Symbols.lightbulb, text: 'Tafsir'),
                  3: TabItem(icon: Symbols.note_add, text: 'Notes'),
                },
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: 20,
                thumbDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green, width: 2),
                  color: Colors.lightGreen,
                ),
                duration: Duration(milliseconds: 100),
                curve: Curves.easeInToLinear,
                onValueChanged: (v) {
                  globalController.setCurrentTabByIndex(v);
                },
              ),
            ),
          ),

          TextButton.icon(
            icon: const Icon(Symbols.ink_highlighter, weight: 300),
            label: Text("Highlights"),
            onPressed: () => globalController.setCurrentTab(HomeTab.highlights),
          ),

          TextButton.icon(
            icon: const Icon(Symbols.font_download, weight: 300),
            label: Text("Settings"),
            onPressed: () => drawerActions.toggleRightDrawer(DrawerComponentKey.settings),
          ),
        ],
      ),
    );
  }
}
