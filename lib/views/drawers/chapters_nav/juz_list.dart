import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/models/juz.dart';
import 'package:quran/providers/navigation/navigation_scroll_provider.dart';
import 'package:quran/repositories/quran/quran_data.dart';
import 'package:quran/views/drawers/chapters_nav/nav_card.dart';


class JuzList extends ConsumerStatefulWidget {
  const JuzList({super.key});

  @override
  ConsumerState<JuzList> createState() => _JuzListState();
}

class _JuzListState extends ConsumerState<JuzList> {
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
    final scrollHelper = ref.read(navigationScrollProvider(NavigationType.juz));
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
      itemCount: QuranData.juzs.length,
      itemBuilder: (BuildContext context, int index) {
        return JuzCard(QuranData.juzs[index]);
      },
    );
  }
}

class JuzCard extends ConsumerWidget {
  const JuzCard(this.juz, {super.key});

  final Juz juz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstAyahText = QuranData.ayahMap["${juz.firstSurah}:${juz.firstAyah}"]?.text ?? "";

    final subtitle =
        "${QuranData.surahMap[juz.firstSurah]?.englishName} ${juz.firstAyahKey}";

    void onSelectedJuz() {
      context.pop();
      ref.read(globalControllerProvider.notifier).goToAyah(juz.firstSurah, juz.firstAyah);
    }

    return NavCard(
      index: juz.juzNumber,
      title: "Juz ${juz.juzNumber}",
      subtitle: subtitle,
      onTap: onSelectedJuz,
      trailingText: firstAyahText
    );
  }
}
