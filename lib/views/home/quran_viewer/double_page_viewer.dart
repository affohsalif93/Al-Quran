import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/providers/home/home_controller.dart';
//
// class BookViewPage extends ConsumerWidget {
//   final int index;
//
//   const BookViewPage({super.key, required this.index});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final homeController = ref.read(homeControllerProvider.notifier);
//
//     final future1 = homeController.getPageWidget(index + 2, ref);
//     final future2 = homeController.getPageWidget(index + 1, ref);
//
//     return FutureBuilder<List<Widget>>(
//       future: Future.wait([future1, future2]),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         final widgets = snapshot.data!;
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [widgets[0], const SizedBox(width: 5), widgets[1]],
//         );
//       },
//     );
//   }
// }
