import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/navigation/navigation_scroll_provider.dart';
import 'package:quran/providers/navigation/navigation_tab_provider.dart';
import 'package:quran/views/drawers/chapters_nav/hizb_list.dart';
import 'package:quran/views/drawers/chapters_nav/juz_list.dart';

import 'package:quran/views/widgets/custom_scaffold.dart';
import 'package:quran/i18n/strings.g.dart';
import 'surah_list.dart';
import 'rub_list.dart';

class SelectSurahView extends ConsumerStatefulWidget {
  const SelectSurahView({super.key});

  @override
  ConsumerState<SelectSurahView> createState() => _SelectSurahViewState();
}

class _SelectSurahViewState extends ConsumerState<SelectSurahView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Set initial tab based on provider state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeTab = ref.read(navigationTabProvider);
      _tabController.index = _getTabIndex(activeTab);
    });

    // Listen for tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != _tabController.previousIndex) {
        final navigationTabNotifier = ref.read(navigationTabProvider.notifier);
        navigationTabNotifier.setActiveTab(_getNavigationType(_tabController.index));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _getTabIndex(NavigationType type) {
    switch (type) {
      case NavigationType.surah:
        return 0;
      case NavigationType.juz:
        return 1;
      case NavigationType.hizb:
        return 2;
      case NavigationType.rub:
        return 3;
    }
  }

  NavigationType _getNavigationType(int index) {
    switch (index) {
      case 0:
        return NavigationType.surah;
      case 1:
        return NavigationType.juz;
      case 2:
        return NavigationType.hizb;
      case 3:
        return NavigationType.rub;
      default:
        return NavigationType.surah;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        // title: Text(context.t.index),
        title: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.t.surahs),
            Tab(text: context.t.juz),
            Tab(text: "Hizb"),
            Tab(text: "Rub"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SurahList(),
          JuzList(),
          HizbList(),
          RubList(),
        ],
      ),
    );
  }
}
