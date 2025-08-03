import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/providers/global/global_controller.dart';

class TafsirView extends ConsumerWidget {
  const TafsirView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalControllerProvider);
    final globalController = ref.read(globalControllerProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
      ),
      padding: EdgeInsets.fromLTRB(10, 20, 5, 20),
    );
  }
}
