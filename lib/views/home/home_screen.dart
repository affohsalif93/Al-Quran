import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/providers/drawer/drawer_provider.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/views/footer/bottom_menu_bar.dart';
import 'package:quran/views/header/top_menu_bar.dart';
import 'package:quran/views/home/viewer/main_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerState = ref.watch(drawerControllerProvider);
    final drawerActions = ref.read(drawerControllerProvider.notifier);

    if (drawerState.isLeftDrawerOpen) {
      globalScaffoldKey.currentState?.openDrawer();
    }
    if (drawerState.isRightDrawerOpen) {
      globalScaffoldKey.currentState?.openEndDrawer();
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: TopMenuBar(),
      ),
      body: Scaffold(
        key: globalScaffoldKey,
        body: MainView(),
        drawer: Drawer(
          width: 350,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: drawerState.leftDrawerComponent,
        ),
        onDrawerChanged: (isOpen) {
          if (!isOpen) {
            drawerActions.closeLeftDrawer();
          }
        },
        endDrawer: Drawer(
          width: 350,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: drawerState.rightDrawerComponent,
        ),
        onEndDrawerChanged: (isOpen) {
          if (!isOpen) {
            drawerActions.closeRightDrawer();
          }
        },
      ),
      bottomNavigationBar: BottomBar(),
      // backgroundColor: context.colors.quranPageBackground,
    );
  }
}
