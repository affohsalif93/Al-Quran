import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:quran/assets/assets.gen.dart';
import 'package:quran/common_widgets/custom_button.dart';
import 'package:quran/common_widgets/svg_icon.dart';
import 'package:quran/extensions/context_extensions.dart';
import 'package:quran/extensions/screen_utils_extensions.dart';
import 'package:quran/i18n/strings.g.dart';
import 'package:quran/router/routes.dart';
import 'tafsir_section.dart';

class TafsirEmptySection extends ConsumerWidget {
  const TafsirEmptySection({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onOpenManageTafsir() async {
      await context.pushNamed(Routes.manageTafsir.name);
      ref.invalidate(tafsirFutureProvider(index));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        40.gapH,
        SvgIcon(
          Assets.icons.quranBook.path,
          size: 100.rm,
          color: context.colors.textSecondary.withOpacity(.5),
        ),
        16.gapH,
        Text(
          context.t.noTafsir,
          textAlign: TextAlign.center,
          style: context.textTheme.labelMedium,
        ),
        16.gapH,
        CustomButton(
          text: context.t.manageTafsir,
          icon: Icons.add,
          onPressed: onOpenManageTafsir,
        ),
      ],
    );
  }
}
