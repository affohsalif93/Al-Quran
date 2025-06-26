import 'package:equatable/equatable.dart';
import 'package:quran/models/mushaf.dart';
import 'package:quran/providers/drawer/drawer_state.dart';

class HomeState extends Equatable {
  final int currentPage;
  final bool isBookView;
  final bool isShowMenu;
  final bool isShowBookmarkMenu;
  final Mushaf currentMushaf;

  const HomeState({
    this.currentPage = 1,
    this.isShowMenu = true,
    this.isShowBookmarkMenu = false,
    this.isBookView = false,
    required this.currentMushaf,
  });

  HomeState copyWith({
    int? currentPage,
    bool? isShowMenu,
    bool? isShowBookmarkMenu,
    bool? isBookView,
    DrawerState? drawerState,
    Mushaf? currentMushaf,
  }) {
    return HomeState(
      currentPage: currentPage ?? this.currentPage,
      isShowMenu: isShowMenu ?? this.isShowMenu,
      isShowBookmarkMenu: isShowBookmarkMenu ?? this.isShowBookmarkMenu,
      isBookView: isBookView ?? this.isBookView,
      currentMushaf: currentMushaf ?? this.currentMushaf,
    );
  }

  HomeState setCurrentPage(int currentPage) {
    return copyWith(currentPage: currentPage);
  }

  HomeState setCurrentPageWithJump(int currentPage) {
    return copyWith(currentPage: currentPage);
  }

  @override
  List<Object?> get props => [
    currentPage,
    isBookView,
    isShowBookmarkMenu,
    isShowMenu,
    currentMushaf,
  ];
}
