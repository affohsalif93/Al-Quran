import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/drawer/drawer_state.dart';
import 'package:quran/providers/global/global_controller.dart';

class DrawerController extends StateNotifier<DrawerState> {
  DrawerController() : super(const DrawerState());

  void toggleLeftDrawer(DrawerComponentKey key) {
    if (state.isLeftDrawerOpen && state.leftDrawerComponentKey == key) {
      closeLeftDrawer();
    } else {
      openLeftDrawer(key);
    }
  }

  void openLeftDrawer(DrawerComponentKey key) {
    state = state.copyWith(
      openedDrawer: "left",
      leftDrawerComponent: drawerComponents[key],
      leftDrawerComponentKey: key,
    );
    globalScaffoldKey.currentState?.openDrawer();
  }

  void closeLeftDrawer() {
    state = state.copyWith(
      openedDrawer: "",
      leftDrawerComponentKey: null,
      leftDrawerComponent: null,
    );
    globalScaffoldKey.currentState?.closeDrawer();
  }

  void toggleRightDrawer(DrawerComponentKey key) {
    if (state.isRightDrawerOpen && state.rightDrawerComponentKey == key) {
      closeRightDrawer();
    } else {
      openRightDrawer(key);
    }
  }

  void openRightDrawer(DrawerComponentKey key) {
    state = state.copyWith(
      openedDrawer: "right",
      rightDrawerComponent: drawerComponents[key],
      rightDrawerComponentKey: key,
    );
    globalScaffoldKey.currentState?.openEndDrawer();
  }

  void closeOpenDrawer() {
    if (state.isLeftDrawerOpen) {
      closeLeftDrawer();
    } else if (state.isRightDrawerOpen) {
      closeRightDrawer();
    }
  }

  void closeRightDrawer() {
    state = state.copyWith(
      openedDrawer: "",
      rightDrawerComponentKey: null,
      rightDrawerComponent: null,
    );
    globalScaffoldKey.currentState?.closeEndDrawer();
  }

  void selectLeftDrawerComponent(DrawerComponentKey componentKey) {
    state = state.copyWith(leftDrawerComponent: drawerComponents[componentKey]);
  }

  void selectRightDrawerComponent(DrawerComponentKey componentKey) {
    state = state.copyWith(rightDrawerComponent: drawerComponents[componentKey]);
  }
}
