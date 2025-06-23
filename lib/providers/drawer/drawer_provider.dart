import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/drawer/drawer_controller.dart';
import 'package:quran/providers/drawer/drawer_state.dart';

final drawerControllerProvider =
StateNotifierProvider<DrawerController, DrawerState>((ref) {
  return DrawerController();
});
