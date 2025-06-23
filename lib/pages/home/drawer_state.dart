import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:quran/pages/home/widgets/chapters/select_chapter_view.dart';
import 'package:quran/pages/home/widgets/select_mushaf/mushaf_list.dart';
import 'package:quran/pages/settings/settings_screen.dart';

enum DrawerComponentKey {
  chapters,
  books,
  settings,
  mushaf,
  notes,
}

final drawerComponents = <DrawerComponentKey, Widget>{
  DrawerComponentKey.chapters: SelectChapterView(),
  DrawerComponentKey.books: Text('Books'),
  DrawerComponentKey.settings: SettingsScreen(),
  DrawerComponentKey.mushaf: MushafList(),
  DrawerComponentKey.notes: Text('Notes'),
};

class DrawerState extends Equatable {
  const DrawerState({
    this.isLeftDrawerOpen = false,
    this.isRightDrawerOpen = false,
    this.leftDrawerComponent,
    this.rightDrawerComponent,
    this.leftDrawerComponentKey,
    this.rightDrawerComponentKey,
  });

  final bool isLeftDrawerOpen;
  final bool isRightDrawerOpen;
  final DrawerComponentKey? leftDrawerComponentKey;
  final DrawerComponentKey? rightDrawerComponentKey;
  final Widget? leftDrawerComponent;
  final Widget? rightDrawerComponent;

  DrawerState copyWith({
    bool? isLeftDrawerOpen,
    bool? isRightDrawerOpen,
    Widget? leftDrawerComponent,
    Widget? rightDrawerComponent,
    DrawerComponentKey? leftDrawerComponentKey,
    DrawerComponentKey? rightDrawerComponentKey,
  }) {
    return DrawerState(
      isLeftDrawerOpen: isLeftDrawerOpen ?? this.isLeftDrawerOpen,
      isRightDrawerOpen: isRightDrawerOpen ?? this.isRightDrawerOpen,
      leftDrawerComponent: leftDrawerComponent ?? this.leftDrawerComponent,
      rightDrawerComponent: rightDrawerComponent ?? this.rightDrawerComponent,
      leftDrawerComponentKey:
      leftDrawerComponentKey ?? this.leftDrawerComponentKey,
      rightDrawerComponentKey:
      rightDrawerComponentKey ?? this.rightDrawerComponentKey,
    );
  }

  @override
  List<Object?> get props => [
    isLeftDrawerOpen,
    isRightDrawerOpen,
    leftDrawerComponent,
    rightDrawerComponent,
    leftDrawerComponentKey,
    rightDrawerComponentKey,
  ];
}
