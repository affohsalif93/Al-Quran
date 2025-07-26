import 'package:equatable/equatable.dart';
import 'package:quran/models/quran/ayah_model.dart';
import 'package:quran/models/mushaf.dart';

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

class GlobalState extends Equatable {
  final int currentPage;
  final ViewerMode viewerMode;
  final bool isShowMenu;
  final Mushaf currentMushaf;
  final HomeTab currentTab;
  final Ayah? selectedAyah;

  const GlobalState({
    this.currentPage = 1,
    this.isShowMenu = true,
    this.viewerMode = ViewerMode.double,
    this.currentTab = HomeTab.mushaf,
    this.selectedAyah,
    required this.currentMushaf,
  });

  GlobalState copyWith({
    int? currentPage,
    bool? isShowMenu,
    ViewerMode? viewerMode,
    Mushaf? currentMushaf,
    HomeTab? currentTab,
    Ayah? selectedAyah,
  }) {
    return GlobalState(
      currentPage: currentPage ?? this.currentPage,
      isShowMenu: isShowMenu ?? this.isShowMenu,
      viewerMode: viewerMode ?? this.viewerMode,
      currentMushaf: currentMushaf ?? this.currentMushaf,
      currentTab: currentTab ?? this.currentTab,
      selectedAyah: selectedAyah ?? this.selectedAyah,
    );
  }

  get isBookView => viewerMode == ViewerMode.double;

  get isViewerToggleEnabled => currentTab == HomeTab.mushaf;

  get isSplitViewer => currentTab != HomeTab.mushaf;

  get isMushafTab => currentTab == HomeTab.mushaf;

  int getCurrentTabIndex() {
    return HomeTab.values.indexOf(currentTab);
  }

  @override
  List<Object?> get props => [
    currentPage,
    viewerMode,
    isShowMenu,
    currentMushaf,
    currentTab,
    selectedAyah,
  ];
}
