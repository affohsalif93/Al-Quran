import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/navigation/navigation_scroll_provider.dart';

// State notifier to manage the active navigation tab
class NavigationTabNotifier extends StateNotifier<NavigationType> {
  NavigationTabNotifier() : super(NavigationType.surah); // Default to surah

  void setActiveTab(NavigationType tab) {
    state = tab;
  }
}

// Provider for the navigation tab state
final navigationTabProvider = StateNotifierProvider<NavigationTabNotifier, NavigationType>((ref) {
  return NavigationTabNotifier();
});