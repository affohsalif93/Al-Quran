import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/utils/logger.dart';
import 'package:quran/providers/home/home_state.dart';
import 'package:quran/repositories/quran/quran_data.dart';
import 'package:quran/providers/shared_preferences_provider.dart';

final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(ref);
});

final currentPageProvider = Provider<int>((ref) {
  return ref.watch(homeControllerProvider).currentPage;
});

class HomeController extends StateNotifier<HomeState> {
  final Ref ref;
  late PageController pageController;

  HomeController(this.ref): super(_initialState((ref))) {
    pageController = PageController(initialPage: state.currentPage - 1);
    ref.onDispose(() {
      pageController.dispose();
    });
  }

  static HomeState _initialState(Ref ref) {
    final prefs = ref.read(sharedPreferencesProvider);
    return HomeState(
      currentPage: prefs.getPageNumber(),
      // currentMushaf: QuranMetadata.mushafs
      //     .firstWhere((m) => m.englishName == prefs.getCurrentMushaf())
      currentMushaf: QuranData.madinahMushafV1,
    );
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
    if (tabValue == HomeTab.mushaf) {
      state = state.copyWith(currentTab: HomeTab.mushaf, viewerMode: ViewerMode.double);
    } else {
      state = state.copyWith(currentTab: tabValue, viewerMode: ViewerMode.single);
    }
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
    state = state.copyWith(
      isShowMenu: !state.isShowMenu,
      isShowBookmarkMenu: false,
    );
  }

  void toggleBookmarkMenu() {
    state = state.copyWith(isShowBookmarkMenu: !state.isShowBookmarkMenu);
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
    final mushaf = QuranData.mushafs
        .firstWhere((mushaf) => mushaf.englishName == name,
        orElse: () {
      logger.error("Mushaf not found: $name");
      return QuranData.madinahMushafV1;
    });

    state = state.copyWith(currentMushaf: mushaf);
    prefs.setCurrentMushaf(name);
  }

  void goToNextPage() {
    if (canGoToNextPage()) {
      if (state.isBookView) {
        state = state.setCurrentPage(state.currentPage + 2);
      } else {
        state = state.setCurrentPage(state.currentPage + 1);
      }
      controllerJumpToPage(state.currentPage); // because 0 based index
      setLastReadPage();
    } else {
      logger.info("Cannot go to next page ${state.currentPage}");
    }
  }

  void goToPreviousPage() {
    if (canGoToPreviousPage()) {
      if (state.isBookView) {
        state = state.setCurrentPage(state.currentPage - 2);
      } else {
        state = state.setCurrentPage(state.currentPage - 1);
      }
      controllerJumpToPage(state.currentPage);
      setLastReadPage();
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
    state = state.setCurrentPage(page);
    setLastReadPage();
  }

  void setCurrentPage(int page) {
    state = state.setCurrentPage(page);
    setLastReadPage();
  }

  void setLastReadPage() {
    prefs.setPageNumber(state.currentPage);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
