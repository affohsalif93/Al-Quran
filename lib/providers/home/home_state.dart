import 'package:equatable/equatable.dart';
import 'package:quran/models/mushaf.dart';
import 'package:quran/providers/drawer/drawer_state.dart';

enum HomeTab {
  mushaf,
  tafsir,
  hifz,
  notes,
}

enum ViewerMode {
  double,
  single,
  translation,
}

class HomeState extends Equatable {
  final int currentPage;
  final ViewerMode viewerMode;
  final bool isShowMenu;
  final bool isShowBookmarkMenu;
  final Mushaf currentMushaf;
  final HomeTab currentTab;

  const HomeState({
    this.currentPage = 1,
    this.isShowMenu = true,
    this.isShowBookmarkMenu = false,
    this.viewerMode = ViewerMode.double,
    this.currentTab = HomeTab.mushaf,
    required this.currentMushaf,
  });

  HomeState copyWith({
    int? currentPage,
    bool? isShowMenu,
    bool? isShowBookmarkMenu,
    ViewerMode? viewerMode,
    DrawerState? drawerState,
    Mushaf? currentMushaf,
    HomeTab? currentTab,
  }) {
    return HomeState(
      currentPage: currentPage ?? this.currentPage,
      isShowMenu: isShowMenu ?? this.isShowMenu,
      isShowBookmarkMenu: isShowBookmarkMenu ?? this.isShowBookmarkMenu,
      viewerMode: viewerMode ?? this.viewerMode,
      currentMushaf: currentMushaf ?? this.currentMushaf,
      currentTab: currentTab ?? this.currentTab,
    );
  }

  get isBookView => viewerMode == ViewerMode.double;

  get isViewerToggleEnabled => currentTab == HomeTab.mushaf;

  get isSplitViewer => currentTab != HomeTab.mushaf;

  HomeState setCurrentPage(int currentPage) {
    return copyWith(currentPage: currentPage);
  }

  int getCurrentTabIndex() {
    return HomeTab.values.indexOf(currentTab);
  }

  @override
  List<Object?> get props => [
    currentPage,
    viewerMode,
    isShowBookmarkMenu,
    isShowMenu,
    currentMushaf,
    currentTab,
  ];
}
