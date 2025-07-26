import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/drawer/drawer_state.dart';
import 'package:quran/providers/global/global_controller.dart';

class DrawerController extends StateNotifier<DrawerState> {
  DrawerController() : super(const DrawerState());

  void toggleLeftDrawer(DrawerComponentKey key) {
    if (state.isLeftDrawerOpen && state.leftDrawerComponentKey == key) {
      closeLeftDrawer();
      return;
    }
    state = state.copyWith(
      isLeftDrawerOpen: true,
      leftDrawerComponent: drawerComponents[key],
      leftDrawerComponentKey: key,
    );
  }

  void closeLeftDrawer() {
    state = state.copyWith(isLeftDrawerOpen: false, leftDrawerComponentKey: null, leftDrawerComponent: null);
    globalScaffoldKey.currentState?.closeDrawer();
  }

  void toggleRightDrawer(DrawerComponentKey key) {
    if (state.isRightDrawerOpen && state.rightDrawerComponentKey == key) {
      closeRightDrawer();
      return;
    }
    state = state.copyWith(
      isRightDrawerOpen: true,
      rightDrawerComponent: drawerComponents[key],
      rightDrawerComponentKey: key,
    );
  }

  void closeRightDrawer() {
    state =
        state.copyWith(isRightDrawerOpen: false, rightDrawerComponentKey: null, rightDrawerComponent: null);
    globalScaffoldKey.currentState?.closeEndDrawer();
  }

  void selectLeftDrawerComponent(DrawerComponentKey componentKey) {
    state = state.copyWith(leftDrawerComponent: drawerComponents[componentKey]);
  }

  void selectRightDrawerComponent(DrawerComponentKey componentKey) {
    state =
        state.copyWith(rightDrawerComponent: drawerComponents[componentKey]);
  }
}
