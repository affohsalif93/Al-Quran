import 'package:flutter/material.dart';

import 'package:quran/providers/quran/quran_data.dart';
import 'chapter_card.dart';

class ChaptersList extends StatelessWidget {
  const ChaptersList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: QuranData.chapters.length,
      itemBuilder: (BuildContext context, int index) {
        return ChapterCard(QuranData.chapters[index]);
      },
    );
  }
}
