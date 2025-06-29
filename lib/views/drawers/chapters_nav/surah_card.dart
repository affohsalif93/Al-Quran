import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/models/surah_model.dart';
import 'package:quran/providers/home/home_controller.dart';
import 'package:quran/providers/surah_name_ligature_provider.dart';

class SurahCard extends ConsumerWidget {
  const SurahCard(this.surah, {super.key});

  final SurahModel surah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahNameLigature = ref.read(surahNameLigatureProvider);

    void onSelectedSurah() {
      context.pop();
      ref.read(homeControllerProvider.notifier).goToPage(surah.firstPage);
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colorScheme.onSurface.withValues(alpha: 0.3))),
      ),
      child: ListTile(
        onTap: onSelectedSurah,
        leading: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: ClipPath(
            clipper: ClipDiamond(),
            child: CircleAvatar(
              child: Text(surah.id.toString(), style: context.textTheme.bodySmall),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            surah.name(context),
            style: TextStyle(
              fontSize: 13.spMin,
              fontWeight: FontWeight.w500,
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
        subtitle: Text(
          surah.dataFormatted(context),
          style: TextStyle(
            fontSize: 12.spMin,
            fontWeight: FontWeight.w400,
            color: context.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        trailing: Text(
          surahNameLigature.getShortName(surah.id),
          style: TextStyle(
            fontSize: 30.spMin,
            fontFamily: surahNameLigature.shortNameFontFamily,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class ClipDiamond extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;
    Path path =
        Path()
          ..moveTo(0, height * 0.5)
          ..lineTo(width * 0.5, 0)
          ..lineTo(width, height * 0.5)
          ..lineTo(width * 0.5, height);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
