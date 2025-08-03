import 'package:flutter/material.dart';
import 'package:quran/repositories/quran/quran_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/models/surah.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/views/drawers/chapters_nav/nav_card.dart';


class SurahList extends StatelessWidget {
  const SurahList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: QuranData.surahs.length,
      itemBuilder: (BuildContext context, int index) {
        return SurahCard(QuranData.surahs[index]);
      },
    );
  }
}

class SurahCard extends ConsumerWidget {
  const SurahCard(this.surah, {super.key});

  final Surah surah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onSelectedSurah() {
      context.pop();
      ref.read(globalControllerProvider.notifier).goToPage(surah.firstPage);
    }

    return NavCard(
      index: surah.id,
      title: surah.name(context),
      subtitle: surah.dataFormatted(context),
      trailingWidget: Text(
        QuranData.namesLigatures.getShortName(surah.id),
        style: TextStyle(
          fontSize: 30.spMin,
          fontFamily: QuranData.namesLigatures.shortNameFontFamily,
          color: Colors.black,
        ),
      ),
      onTap: onSelectedSurah,
    );
  }
}
