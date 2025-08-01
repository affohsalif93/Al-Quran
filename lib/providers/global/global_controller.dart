import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/ayah_model.dart';
import 'package:quran/providers/global/global_state.dart';
import 'package:quran/providers/shared_preferences_provider.dart';
import 'package:quran/repositories/quran/static_quran_data.dart';

final GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();

final globalControllerProvider = StateNotifierProvider<GlobalController, GlobalState>((ref) {
  return GlobalController(ref);
});

final currentPageProvider = Provider<int>((ref) {
  return ref.watch(globalControllerProvider).currentPage;
});

class GlobalController extends StateNotifier<GlobalState> {
  final Ref ref;
  late PageController pageController;

  GlobalController(this.ref) : super(_initialState((ref))) {
    pageController = PageController(initialPage: state.currentPage - 1);
    ref.onDispose(() {
      pageController.dispose();
    });
  }

  static GlobalState _initialState(Ref ref) {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedZoom = prefs.getZoomLevel().clamp(0.5, 2.0);
    return GlobalState(
      currentPage: prefs.getPageNumber(),
      currentMushaf: StaticQuranData.madinahMushafV1,
      zoomLevel: savedZoom,
    );
  }

  // GETTERS AND UTILITY METHODS

  SharedPreferencesService get prefs => ref.read(sharedPreferencesProvider);

  int getMushafPageCount() {
    return state.currentMushaf.numberOfPages;
  }

  int getCurrentTabIndex() {
    return HomeTab.values.indexOf(state.currentTab) + 1;
  }

  String getCurrentPageText() {
    if (state.isBookView) {
      return "Pages ${state.currentPage + 1} - ${state.currentPage}";
    }
    return "Page ${state.currentPage}";
  }

  String getCurrentMushafName() {
    return state.currentMushaf.englishName;
  }

  bool shouldFocusFirstAyahOfPage() {
    return !state.isMushafTab && state.selectedAyah == null;
  }

  // AYAH SELECTION

  void setSelectedAyah(Ayah ayah) {
    state = state.copyWith(selectedAyah: ayah);
  }

  void clearSelectedAyah() {
    state = state.copyWith(selectedAyah: null);
  }

  // TAB MANAGEMENT

  void setCurrentTabByIndex(int index) {
    if (index < 1 || index > HomeTab.values.length) {
      logger.error("Invalid tab index: $index");
      return;
    }
    final tabValue = HomeTab.values[index - 1];
    _switchTab(tabValue);
  }

  void _switchTab(HomeTab tab) {
    if (tab == HomeTab.mushaf) {
      state = state.copyWith(currentTab: HomeTab.mushaf);
    } else {
      state = state.copyWith(currentTab: tab);
    }
  }

  void toTafsirTab() {
    state = state.copyWith(currentTab: HomeTab.tafsir, viewMode: ViewMode.single);
  }

  // UI CONTROLS

  void toggleMenu() {
    state = state.copyWith(isShowMenu: !state.isShowMenu);
  }

  void setViewMode(ViewMode viewMode) {
    if (viewMode == state.viewMode) {
      return;
    }
    if (viewMode == ViewMode.single) {
      state = state.copyWith(viewMode: viewMode);
    } else if (viewMode == ViewMode.double) {
      final currentPage = state.currentPage - (state.currentPage.isEven ? 1 : 0);
      state = state.copyWith(viewMode: viewMode, currentPage: currentPage);
      controllerJumpToPage(currentPage);
    }
  }

  // MUSHAF MANAGEMENT

  void setCurrentMushaf(String name) {
    final mushaf = StaticQuranData.mushafs.firstWhere(
      (mushaf) => mushaf.englishName == name,
      orElse: () {
        logger.error("Mushaf not found: $name");
        return StaticQuranData.madinahMushafV1;
      },
    );

    state = state.copyWith(currentMushaf: mushaf);
    prefs.setCurrentMushaf(name);
  }

  // PAGE NAVIGATION

  void controllerJumpToPage(int page) {
    if (pageController.hasClients) {
      pageController.jumpToPage(page - 1); // because 0 based index
    } else {
      logger.error("PageController has no clients");
    }
  }

  bool canGoToPreviousPage() {
    if (state.isBookView) {
      return state.currentPage > 2;
    }
    return state.currentPage > 1;
  }

  bool canGoToNextPage() {
    if (state.isBookView) {
      return state.currentPage < 603;
    }
    return state.currentPage < 604;
  }

  void goToNextPage() {
    if (canGoToNextPage()) {
      final currentPage = state.currentPage + (state.isBookView ? 2 : 1);
      controllerJumpToPage(currentPage);
      setCurrentPage(currentPage);
    } else {
      logger.info("Cannot go to next page ${state.currentPage}");
    }
  }

  void goToPreviousPage() {
    if (canGoToPreviousPage()) {
      final currentPage = state.currentPage - (state.isBookView ? 2 : 1);
      controllerJumpToPage(currentPage);
      setCurrentPage(currentPage);
    }
  }

  void goToPage(int page) {
    if (page < 1 || page > 604) {
      logger.error("Invalid page number: $page");
      return;
    }
    if (state.isBookView && page.isEven) {
      page = page - 1;
    }
    controllerJumpToPage(page);
    setCurrentPage(page);
  }

  void goToAyah(int surah, int ayah) {
    final page = StaticQuranData.getPageNumber(surah, ayah);
    if (page > 0) {
      goToPage(page);
    } else {
      logger.error("Ayah $surah:$ayah not found in Quran data");
    }
  }

  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
    prefs.setPageNumber(state.currentPage);
  }

  // ZOOM FUNCTIONALITY

  void setZoomLevel(double zoomLevel) {
    if (zoomLevel < 0.5 || zoomLevel > 2.0) {
      logger.error("Invalid zoom level: $zoomLevel. Must be between 0.5 and 2.0");
      return;
    }
    state = state.copyWith(zoomLevel: zoomLevel);
    prefs.setZoomLevel(zoomLevel);
  }

  void resetZoom() {
    setZoomLevel(1.0);
  }

  void zoomIn() {
    final newZoom = (state.zoomLevel + 0.05).clamp(0.5, 1.0);
    setZoomLevel(newZoom);
  }

  void zoomOut() {
    final newZoom = (state.zoomLevel - 0.05).clamp(0.5, 1.0);
    setZoomLevel(newZoom);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
