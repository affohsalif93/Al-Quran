import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/debug/logger.dart';
import 'package:quran/extensions/mushaf_extensions.dart';
import 'package:quran/pages/home/home_state.dart';
import 'package:quran/providers/quran/quran_data.dart';
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
    pageController = PageController(initialPage: state.currentPage);
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

  SharedPreferencesService get prefs => ref.read(sharedPreferencesProvider);

  Future<Widget> getPageWidget(int pageNumber, WidgetRef wRef) {
    return state.currentMushaf.getPageWidget(pageNumber, wRef);
  }

  int getMushafPageCount() {
    return state.currentMushaf.numberOfPages;
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

  void setViewMode(String viewMode) {
    if (viewMode == 'single') {
      state = state.copyWith(isBookView: false);
    } else if (viewMode == 'double') {
      state = state.copyWith(isBookView: true);
      if (state.currentPage.isEven) {
        state = state.copyWith(currentPage: state.currentPage - 1);
        pageController.jumpToPage(state.currentPage - 1);
      }
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
      pageController.jumpToPage(state.currentPage - 1); // because 0 based index
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
      pageController.jumpToPage(state.currentPage - 1); // because 0 based index
      setLastReadPage();
    }
  }

  void goToPage(int page) {
    if (page < 1 || page > 604) {
      logger.error("Invalid page number: $page");
      return;
    }
    // offset if book view
    if (state.isBookView && page.isEven) {
        page = page - 1;
    }
    pageController.jumpToPage(page);
    state = state.setCurrentPageWithJump(page);
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
