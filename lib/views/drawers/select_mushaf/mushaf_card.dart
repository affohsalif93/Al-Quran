import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/models/mushaf.dart';
import 'package:quran/providers/drawer/drawer_provider.dart';
import 'package:quran/providers/drawer/drawer_state.dart';
import 'package:quran/providers/home/home_controller.dart';

class MushafCard extends ConsumerWidget {
  const MushafCard(this.mushaf, {super.key});
  final Mushaf mushaf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerActions = ref.read(drawerControllerProvider.notifier);
    final isCurrentMushaf = ref.watch(homeControllerProvider).currentMushaf.id == mushaf.id;

    void selectMushaf() {
      drawerActions.toggleRightDrawer(DrawerComponentKey.mushaf);
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: BoxDecoration(
        color: isCurrentMushaf
            ? context.colorScheme.primary.withOpacity(.1)
            : context.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.onSurface.withOpacity(.03),
          ),
        ),
      ),
      child: ListTile(
        onTap: selectMushaf,
        leading: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Image.file(File(mushaf.coverImage)),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 3.0),
          child: Text(mushaf.name(context)),
        ),
        subtitle: Text(mushaf.description()),
        trailing: Icon(
          Symbols.arrow_forward_ios,
          size: 14.spMin,
          color: context.colorScheme.onSurface.withOpacity(.4),
        ),
      ),
    );
  }
}
