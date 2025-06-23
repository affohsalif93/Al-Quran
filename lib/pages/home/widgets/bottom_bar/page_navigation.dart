import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:material_symbols_icons/symbols.dart';
import 'package:quran/pages/home/home_controller.dart';

class PageNavigation extends ConsumerWidget {

  const PageNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeController = ref.read(homeControllerProvider.notifier);
    final homeState = ref.watch(homeControllerProvider);

    return Container(
      alignment: Alignment.center,
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: homeController.goToNextPage,
            icon: Icon(
              Symbols.arrow_back_rounded,
              color: Colors.green,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: Colors.green,
                ),
              ),
            ),
          ),
          Container(
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.green,
              ),
            ),
            child: Center(
              child: Text(homeController.getCurrentPageText()),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: homeController.goToPreviousPage,
            icon: Icon(
              Symbols.arrow_forward_rounded,
              color: Colors.green,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
