import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/assets/fonts.gen.dart';
import 'package:quran/views/drawers/chapters_nav/clip_diamond.dart';

class NavCard extends StatelessWidget {
  const NavCard({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
    this.trailingText = "",
    this.trailingWidget,
    this.onTap,
  });

  final int index;
  final String title;
  final String subtitle;
  final String trailingText;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: ClipPath(
            clipper: ClipDiamond(),
            child: CircleAvatar(
              child: Text(index.toString(), style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.spMin,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.spMin,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        trailing: trailingWidget ?? SizedBox(
          width: 150,
          child: Text(
            trailingText,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            style: TextStyle(
              fontSize: 18.spMin,
              color: Colors.black,
              fontFamily: FontFamily.uthmanicHafs,
            ),
          ),
        ),
      ),
    );
  }
}
