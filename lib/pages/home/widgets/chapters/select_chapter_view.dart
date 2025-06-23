import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quran/common_widgets/custom_scaffold.dart';
import 'package:quran/i18n/strings.g.dart';
import 'chapters_list.dart';
import 'quarters_list.dart';

class SelectChapterView extends ConsumerWidget {
  const SelectChapterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: CustomScaffold(
        appBar: AppBar(
          // title: Text(context.t.index),
          title: TabBar(
            tabs: [
              Tab(text: context.t.chapters),
              Tab(text: context.t.quarters),
              Tab(text: context.t.chapters),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ChaptersList(),
            QuartersList(),
            ChaptersList(),
          ],
        ),
      ),
    );
  }
}
