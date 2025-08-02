import 'dart:async';

import 'package:flutter/material.dart';

import 'package:animations/animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:quran/assets/fonts.gen.dart';
import 'package:quran/core/extensions/context_extensions.dart';

abstract class Azkar {
  static final azkarList = [
    Zikr(
      'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      const Duration(seconds: 4),
    ),
    Zikr(
      'سُبْحَانَ اللهِ العَظِيمِ وَبِحَمْدِهِ',
      const Duration(seconds: 5),
    ),
    Zikr(
      'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      const Duration(seconds: 5),
    ),
    Zikr(
      'لَا إلَه إلّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلُّ شَيْءِ قَدِيرِ.',
      const Duration(seconds: 12),
    ),
    Zikr(
      'لا حَوْلَ وَلا قُوَّةَ إِلا بِاللَّهِ',
      const Duration(seconds: 5),
    ),
    Zikr(
      'أستغفر الله',
      const Duration(seconds: 4),
    ),
    Zikr(
      'سُبْحَانَ الْلَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا الْلَّهُ، وَالْلَّهُ أَكْبَرُ ',
      const Duration(seconds: 6),
    ),
    Zikr(
      'لَا إِلَهَ إِلَّا اللَّهُ',
      const Duration(seconds: 4),
    ),
  ];
}

class Zikr {
  final String text;
  final Duration duration;

  Zikr(this.text, this.duration);
}

class AzkarSlider extends HookWidget {
  const AzkarSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final index = useState(0);
    final timerRef = useRef<Timer?>(null);

    // Change surahs with dynamic duration
    useEffect(() {
      void changeIndex() {
        index.value = (index.value + 1) % Azkar.azkarList.length;
        Duration duration = Azkar.azkarList[index.value].duration;
        timerRef.value = Timer(duration, changeIndex);
      }

      // Start the first timer
      timerRef.value = Timer(Azkar.azkarList[index.value].duration, changeIndex);

      return () {
        timerRef.value?.cancel();
      };
    }, []);

    return PageTransitionSwitcher(
      duration: 300.ms,
      reverse: true,
      transitionBuilder: (
        Widget child,
        Animation<double> primaryAnimation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          fillColor: Colors.transparent,
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: child,
        );
      },
      layoutBuilder: (List<Widget> entries) {
        return Stack(
          alignment: Alignment.topCenter,
          children: entries,
        );
      },
      child: Animate(
        key: ValueKey(index.value),
        effects: [
          BlurEffect(
            delay: 100.ms,
            duration: 400.ms,
            curve: Curves.easeOut,
            begin: const Offset(4, 4),
            end: Offset.zero,
          ),
        ],
        child: Text(
          Azkar.azkarList[index.value].text,
          key: ValueKey(index.value),
          style: context.textTheme.titleLarge?.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w400,
            fontFamily: FontFamily.uthmanTN,
            fontSize: 36.spMin,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
