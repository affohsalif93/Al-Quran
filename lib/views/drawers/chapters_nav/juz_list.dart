import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:quran/assets/fonts.gen.dart';
import 'package:quran/models/juz_model.dart';
import 'package:quran/providers/global/global_controller.dart';
import 'package:quran/repositories/quran/static_quran_data.dart';
import 'package:quran/views/drawers/chapters_nav/nav_card.dart';

class JuzList extends StatelessWidget {
  const JuzList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: StaticQuranData.juzs.length,
      itemBuilder: (BuildContext context, int index) {
        return JuzCard(StaticQuranData.juzs[index]);
      },
    );
  }
}

class JuzCard extends ConsumerWidget {
  const JuzCard(this.juz, {super.key});

  final JuzModel juz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstAyahText = StaticQuranData.ayahMap["${juz.firstSurah}:${juz.firstAyah}"]?.text ?? "";

    final subtitle =
        "${StaticQuranData.surahMap[juz.firstSurah]?.englishName} ${juz.firstAyahKey}";

    void onSelectedJuz() {
      context.pop();
      ref.read(globalControllerProvider.notifier).goToAyah(juz.firstSurah, juz.firstAyah);
    }

    return NavCard(
      index: juz.juzNumber,
      title: "Juz ${juz.juzNumber}",
      subtitle: subtitle,
      onTap: onSelectedJuz,
      trailing: SizedBox(
        width: 150,
        child: Text(
          firstAyahText,
          textDirection: TextDirection.rtl,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            fontSize: 15.spMin,
            color: Colors.black,
            fontFamily: FontFamily.digitalKhatt,
          ),
        ),
      ),
    );
  }
}
