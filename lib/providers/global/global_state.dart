import 'package:equatable/equatable.dart';
import 'package:quran/models/quran/ayah_model.dart';
import 'package:quran/models/mushaf.dart';

enum HomeTab {
  mushaf,
  tafsir,
  notes,
}

enum ViewMode {
  double,
  single,
  translation,
}

class GlobalState extends Equatable {
  final int currentPage;
  final ViewMode viewMode;
  final bool isShowMenu;
  final Mushaf currentMushaf;
  final HomeTab currentTab;
  final Ayah selectedAyah;
  final double zoomLevel;

  const GlobalState({
    this.currentPage = 1,
    this.isShowMenu = true,
    this.viewMode = ViewMode.double,
    this.currentTab = HomeTab.mushaf,
    this.selectedAyah = const Ayah(page: 1, surah: 1, ayah: 1, text: ""),
    this.zoomLevel = 1.0,
    required this.currentMushaf,
  });

  GlobalState copyWith({
    int? currentPage,
    bool? isShowMenu,
    ViewMode? viewMode,
    Mushaf? currentMushaf,
    HomeTab? currentTab,
    Ayah? selectedAyah,
    double? zoomLevel,
  }) {
    return GlobalState(
      currentPage: currentPage ?? this.currentPage,
      isShowMenu: isShowMenu ?? this.isShowMenu,
      viewMode: viewMode ?? this.viewMode,
      currentMushaf: currentMushaf ?? this.currentMushaf,
      currentTab: currentTab ?? this.currentTab,
      selectedAyah: selectedAyah ?? this.selectedAyah,
      zoomLevel: zoomLevel ?? this.zoomLevel,
    );
  }

  get isBookView => viewMode == ViewMode.double;

  get isSplitViewer => currentTab != HomeTab.mushaf;

  get isMushafTab => currentTab == HomeTab.mushaf;

  int getCurrentTabIndex() {
    return HomeTab.values.indexOf(currentTab);
  }

  @override
  List<Object?> get props => [
    currentPage,
    viewMode,
    isShowMenu,
    currentMushaf,
    currentTab,
    selectedAyah,
    zoomLevel,
  ];
}
