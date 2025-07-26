import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/views/drawers/chapters_nav/hizb_list.dart';
import 'package:quran/views/drawers/chapters_nav/juz_list.dart';

import 'package:quran/views/widgets/custom_scaffold.dart';
import 'package:quran/i18n/strings.g.dart';
import 'surah_list.dart';
import 'rub_list.dart';

class SelectSurahView extends ConsumerWidget {
  const SelectSurahView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: CustomScaffold(
        appBar: AppBar(
          // title: Text(context.t.index),
          title: TabBar(
            tabs: [
              Tab(text: context.t.surahs),
              Tab(text: context.t.juz),
              Tab(text: "Hizb"),
              Tab(text: "Rub"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SurahList(),
            JuzList(),
            HizbList(),
            RubList(),
          ],
        ),
      ),
    );
  }
}
