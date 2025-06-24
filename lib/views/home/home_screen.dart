import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/providers/drawer/drawer_provider.dart';
import 'package:quran/providers/home/home_controller.dart';
import 'package:quran/views/footer/bottom_menu_bar.dart';
import 'package:quran/views/header/top_menu_bar.dart';
import 'package:quran/views/home/quran_viewer/quran_viewer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerState = ref.watch(drawerControllerProvider);
    final drawerActions = ref.read(drawerControllerProvider.notifier);

    if (drawerState.isLeftDrawerOpen) {
      homeScaffoldKey.currentState?.openDrawer();
    }
    if (drawerState.isRightDrawerOpen) {
      homeScaffoldKey.currentState?.openEndDrawer();
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: TopMenuBar(),
      ),
      body: Scaffold(
        key: homeScaffoldKey,
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xFFDEDEDE),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 30,
          ),
          child: QuranViewer(),
        ),
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
      backgroundColor: context.colors.quranPageBackground,
    );
  }
}
