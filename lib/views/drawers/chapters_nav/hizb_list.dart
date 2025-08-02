import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:quran/assets/fonts.gen.dart';
import 'package:quran/models/hizb_model.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/repositories/quran/static_quran_data.dart';
import 'package:quran/views/drawers/chapters_nav/nav_card.dart';

class HizbList extends StatelessWidget {
  const HizbList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: StaticQuranData.hizbs.length,
      itemBuilder: (BuildContext context, int index) {
        return HizbCard(StaticQuranData.hizbs[index]);
      },
    );
  }
}

class HizbCard extends ConsumerWidget {
  const HizbCard(this.hizb, {super.key});

  final HizbModel hizb;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstAyahText = StaticQuranData.ayahMap[hizb.firstAyahKey]?.text ?? "";

    final subtitle =
        "${StaticQuranData.surahMap[hizb.firstSurah]?.englishName ?? ""} ${hizb.firstAyahKey}";

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
