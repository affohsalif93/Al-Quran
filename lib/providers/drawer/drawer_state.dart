import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:quran/views/drawers/chapters_nav/select_chapter_view.dart';
import 'package:quran/views/drawers/select_mushaf/mushaf_list.dart';
import 'package:quran/views/settings/settings_screen.dart';

enum DrawerComponentKey {
  surahs,
  books,
  settings,
  mushaf,
  notes,
}

final drawerComponents = <DrawerComponentKey, Widget>{
  DrawerComponentKey.surahs: SelectSurahView(),
  DrawerComponentKey.books: Text('Books'),
  DrawerComponentKey.settings: SettingsScreen(),
  DrawerComponentKey.mushaf: MushafList(),
  DrawerComponentKey.notes: Text('Notes'),
};

class DrawerState extends Equatable {
  const DrawerState({
    this.openedDrawer = "",
    this.leftDrawerComponent,
    this.rightDrawerComponent,
    this.leftDrawerComponentKey,
    this.rightDrawerComponentKey,
  });

  final String openedDrawer;
  final DrawerComponentKey? leftDrawerComponentKey;
  final DrawerComponentKey? rightDrawerComponentKey;
  final Widget? leftDrawerComponent;
  final Widget? rightDrawerComponent;

  DrawerState copyWith({
    String? openedDrawer,
    Widget? leftDrawerComponent,
    Widget? rightDrawerComponent,
    DrawerComponentKey? leftDrawerComponentKey,
    DrawerComponentKey? rightDrawerComponentKey,
  }) {
    return DrawerState(
      openedDrawer: openedDrawer ?? this.openedDrawer,
      leftDrawerComponent: leftDrawerComponent ?? this.leftDrawerComponent,
      rightDrawerComponent: rightDrawerComponent ?? this.rightDrawerComponent,
      leftDrawerComponentKey:
      leftDrawerComponentKey ?? this.leftDrawerComponentKey,
      rightDrawerComponentKey:
      rightDrawerComponentKey ?? this.rightDrawerComponentKey,
    );
  }

  get isLeftDrawerOpen => openedDrawer == "left";
  get isRightDrawerOpen => openedDrawer == "right";

  @override
  List<Object?> get props => [
    openedDrawer,
    leftDrawerComponent,
    rightDrawerComponent,
    leftDrawerComponentKey,
    rightDrawerComponentKey,
  ];
}
