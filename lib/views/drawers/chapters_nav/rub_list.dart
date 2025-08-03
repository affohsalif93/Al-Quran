import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:quran/assets/fonts.gen.dart';
import 'package:quran/models/rub.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/repositories/quran/quran_data.dart';
import 'package:quran/views/drawers/chapters_nav/nav_card.dart';

class RubList extends StatelessWidget {
  const RubList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: QuranData.rubs.length,
      itemBuilder: (BuildContext context, int index) {
        return RubCard(QuranData.rubs[index]);
      },
    );
  }
}

class RubCard extends ConsumerWidget {
  const RubCard(this.rub, {super.key});

  final Rub rub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahKey = "${rub.firstSurah}:${rub.firstAyah}";
    final firstAyahText = QuranData.ayahMap[ayahKey]?.text ?? "";
    final subtitle = "${QuranData.surahMap[rub.firstSurah]?.englishName} ${rub.firstAyahKey}";

    void onSelectedRub() {
      context.pop();
      ref.read(globalControllerProvider.notifier).goToAyah(rub.firstSurah, rub.firstAyah);
    }

    return NavCard(
      index: rub.rubNumber,
      title: "Rub ${rub.rubNumber}",
      subtitle: subtitle,
      onTap: onSelectedRub,
      trailingText: firstAyahText,
    );
  }
}
