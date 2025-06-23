import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quran/extensions/context_extensions.dart';
import 'package:quran/extensions/screen_utils_extensions.dart';
import 'package:quran/utils/constants.dart';
import 'tafsir_bottom_sheet.dart';
import 'tafsir_controller.dart';
import 'tafsir_section.dart';
import 'verse_widget.dart';

class TafsirContent extends ConsumerWidget {
  const TafsirContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = ref.watch(scrollControllerProvider);
    final notifier = ref.read(tafsirControllerProvider.notifier);

    return PageView.builder(
      itemCount: Constants.versesCount,
      controller: notifier.pageController,
      onPageChanged: notifier.onPageChanged,
      reverse: context.isLtr,
      itemBuilder: (context, index) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.hm, vertical: 16.wm),
          child: Column(
            children: [
              VerseWidget(index: index),
              24.gapH,
              TafsirSection(index: index),
            ],
          ),
        );
      },
    );
  }
}
