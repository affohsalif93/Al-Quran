import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/providers/drawer/drawer_provider.dart';
import 'package:quran/providers/drawer/drawer_state.dart';
import 'package:quran/providers/global/global_controller.dart';

class SelectMushaf extends ConsumerWidget {
  const SelectMushaf({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeActions = ref.watch(globalControllerProvider.notifier);
    final drawerActions = ref.read(drawerControllerProvider.notifier);

    // add icon to the button
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(
          color: Colors.green,
          width: 0.3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 40),
      ),
      onPressed: () {
        drawerActions.toggleRightDrawer(DrawerComponentKey.mushaf);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.book_fill,
            size: 18.spMin,
            color: Colors.green,
          ),
          SizedBox(width: 15),
          Text(
            homeActions.getCurrentMushafName(),
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }
}
