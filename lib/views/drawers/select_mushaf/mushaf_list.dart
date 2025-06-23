import 'package:flutter/material.dart';

import 'package:quran/views/widgets/custom_scaffold.dart';
import 'package:quran/repositories/quran/quran_data.dart';
import 'package:quran/views/drawers/select_mushaf/mushaf_card.dart';

class MushafList extends StatelessWidget {
  const MushafList({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: Text("Select Mushaf"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        itemCount: QuranData.mushafs.length,
        itemBuilder: (BuildContext context, int index) {
          return MushafCard(QuranData.mushafs[index]);
        },
      ),
    );
  }
}
