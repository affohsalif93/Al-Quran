import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quran/providers/shared_preferences_provider.dart';
import '../../providers/global/global_controller.dart';

final bookmarkControllerProvider =
    StateNotifierProvider<BookmarkController, int?>((ref) {
  return BookmarkController(ref);
});

class BookmarkController extends StateNotifier<int?> {
  final Ref ref;
  BookmarkController(this.ref)
      : super(ref.read(sharedPreferencesProvider).getBookmark());

  void setBookmark(int bookmark) {
    if (bookmark == state) {
      removeBookmark();
      return;
    }

    state = bookmark;
    ref.read(sharedPreferencesProvider).setBookmark(bookmark);
  }

  void removeBookmark() {
    state = null;
    ref.read(sharedPreferencesProvider).setBookmark(null);
  }

  void goToBookmark() {
    if (state != null) {
      ref.read(globalControllerProvider.notifier).goToPage(state!);
    }
  }
}
