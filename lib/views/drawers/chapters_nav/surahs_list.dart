import 'package:flutter/material.dart';
import 'package:quran/repositories/quran/quran_data.dart';
import 'package:quran/views/drawers/chapters_nav/surah_card.dart';


class SurahsList extends StatelessWidget {
  const SurahsList({super.key});

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
