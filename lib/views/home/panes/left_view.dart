import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/providers/home/home_controller.dart';
import 'package:quran/views/home/viewer/double_page_view.dart';
import 'package:quran/views/home/viewer/quran_viewer.dart';
import 'package:quran/views/home/viewer/single_page_view.dart';

class LeftView extends ConsumerWidget {
  const LeftView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final homeController = ref.read(homeControllerProvider.notifier);

    return Container(
      // decoration: BoxDecoration(
      //     color: const Color(0xFFF6F7F8),
      // ),
      margin: EdgeInsets.fromLTRB(10, 20, 5, 20),
      child: QuranViewer(),
    );
  }
}
