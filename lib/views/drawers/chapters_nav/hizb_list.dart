import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran/models/hizb.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/providers/navigation/navigation_scroll_provider.dart';
import 'package:quran/repositories/quran_data.dart';
import 'package:quran/views/drawers/chapters_nav/nav_card.dart';

class HizbList extends ConsumerStatefulWidget {
  const HizbList({super.key});

  @override
  ConsumerState<HizbList> createState() => _HizbListState();
}

class _HizbListState extends ConsumerState<HizbList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentPage();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentPage() {
    final scrollHelper = ref.read(navigationScrollProvider(NavigationType.hizb));
    scrollHelper.scrollToCurrentPage(_scrollController);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(currentPageProvider, (previous, next) {
      if (previous != next) {
        _scrollToCurrentPage();
      }
    });

    return ListView.builder(
      controller: _scrollController,
      itemCount: QuranData.hizbs.length,
      itemBuilder: (BuildContext context, int index) {
        return HizbCard(QuranData.hizbs[index]);
      },
    );
  }
}

class HizbCard extends ConsumerWidget {
  const HizbCard(this.hizb, {super.key});

  final Hizb hizb;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstAyahText = QuranData.ayahMap[hizb.firstAyahKey]?.text ?? "";

    final subtitle =
        "${QuranData.surahMap[hizb.firstSurah]?.englishName ?? ""} ${hizb.firstAyahKey}";

    void onSelectedHizb() {
      context.pop();
      ref.read(globalControllerProvider.notifier).goToAyah(hizb.firstSurah, hizb.firstAyah);
    }

    return NavCard(
      index: hizb.hizbNumber,
      title: "Hizb ${hizb.hizbNumber}",
      subtitle: subtitle,
      onTap: onSelectedHizb,
      trailingText: firstAyahText,
    );
  }
}
