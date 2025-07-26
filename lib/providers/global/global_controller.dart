import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/models/quran/ayah_model.dart';
import 'package:quran/providers/global/global_state.dart';
import 'package:quran/repositories/quran/static_quran_data.dart';
import 'package:quran/providers/shared_preferences_provider.dart';

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
    return GlobalState(
      currentPage: prefs.getPageNumber(),
      currentMushaf: StaticQuranData.madinahMushafV1,
    );
  }

  void setSelectedAyah(Ayah ayah) {
    state = state.copyWith(selectedAyah: ayah);
  }

  void clearSelectedAyah() {
    state = state.copyWith(selectedAyah: null);
  }

  void controllerJumpToPage(int page) {
    if (pageController.hasClients) {
      pageController.jumpToPage(page - 1); // because 0 based index
    } else {
      logger.error("PageController has no clients");
    }
  }

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
      state = state.copyWith(
        currentTab: HomeTab.mushaf,
        viewerMode: ViewerMode.double,
      );
    } else {
      state = state.copyWith(
        currentTab: tab,
        viewerMode: ViewerMode.single,
      );
    }
  }

  bool shouldFocusFirstAyahOfPage() {
    return !state.isMushafTab && state.selectedAyah == null;
  }

  SharedPreferencesService get prefs => ref.read(sharedPreferencesProvider);

  int getMushafPageCount() {
    return state.currentMushaf.numberOfPages;
  }

  int getCurrentTabIndex() {
    return HomeTab.values.indexOf(state.currentTab) + 1;
  }

  void toTafsirTab() {
    state = state.copyWith(currentTab: HomeTab.tafsir, viewerMode: ViewerMode.single);
  }

  void toggleMenu() {
    state = state.copyWith(isShowMenu: !state.isShowMenu);
  }

  String getCurrentPageText() {
    if (state.isBookView) {
      return "Pages ${state.currentPage + 1} - ${state.currentPage}";
    }
    return "Page ${state.currentPage}";
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

  void setViewMode(ViewerMode viewMode) {
    if (viewMode == ViewerMode.single) {
      state = state.copyWith(viewerMode: viewMode);
    } else if (viewMode == ViewerMode.double) {
      final currentPage = state.currentPage - (state.currentPage.isEven ? 1 : 0);
      state = state.copyWith(viewerMode: viewMode, currentPage: currentPage);
      controllerJumpToPage(currentPage);
    }
  }

  String getCurrentMushafName() {
    return state.currentMushaf.englishName;
  }

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

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
