import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/home/home_controller.dart';

class TafsirView extends ConsumerWidget {
  const TafsirView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final homeController = ref.read(homeControllerProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
      ),
      padding: EdgeInsets.fromLTRB(10, 20, 5, 20),
    );
  }
}
