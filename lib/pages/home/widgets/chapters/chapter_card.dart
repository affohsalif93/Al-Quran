import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:quran/extensions/context_extensions.dart';
import 'package:quran/models/chapter_model.dart';
import 'package:quran/pages/home/home_controller.dart';

class ChapterCard extends ConsumerWidget {
  const ChapterCard(this.chapter, {super.key});

  final ChapterModel chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onSelectedChapter() {
      context.pop();
      ref.read(homeControllerProvider.notifier).goToPage(chapter.firstPage);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 4,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.onSurface.withOpacity(.03),
          ),
        ),
      ),
      child: ListTile(
        onTap: onSelectedChapter,
        leading: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: ClipPath(
            clipper: ClipDiamond(),
            child: CircleAvatar(
              child: Text(
                chapter.id.toString(),
                style: context.textTheme.bodySmall,
              ),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(chapter.name(context),
              style: TextStyle(
                fontSize: 13.spMin,
                fontWeight: FontWeight.w500,
                color: context.colorScheme.onSurface,
              )),
        ),
        subtitle: Text(
            chapter.dataFormatted(context),
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w400,
              color: context.colorScheme.onSurface.withOpacity(.5),
            )),
        trailing: Icon(
          Symbols.arrow_forward_ios,
          size: 14.spMin,
          color: context.colorScheme.onSurface.withOpacity(.4),
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
    Path path = Path()
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
