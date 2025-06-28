import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/home/home_controller.dart';
import 'package:quran/views/home/viewer/tafsir_view.dart';


class RightView extends ConsumerWidget {
  const RightView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final homeController = ref.read(homeControllerProvider.notifier);

    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF6F7F8),
      ),
      margin: EdgeInsets.fromLTRB(5, 20, 10, 20),
      child: TafsirView(),
    );
  }
}
