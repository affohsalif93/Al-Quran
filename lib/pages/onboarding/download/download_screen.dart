import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:quran/assets/assets.gen.dart';
import 'package:quran/common_widgets/custom_scaffold.dart';
import 'package:quran/common_widgets/scrollable_column.dart';
import 'package:quran/common_widgets/svg_icon.dart';
import 'package:quran/extensions/context_extensions.dart';
import 'package:quran/extensions/screen_utils_extensions.dart';
import 'package:quran/i18n/strings.g.dart';
import '../onboarding_controller.dart';
import '../azkar.dart';
import '../widgets/download_progress_bar.dart';

class DownloadScreen extends HookConsumerWidget {
  const DownloadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(onboardingControllerProvider);

    return CustomScaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: ScrollableColumn(
        constraintMinHeight: true,
        crossAxisAlignment: CrossAxisAlignment.center,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
        children: [
          SizedBox(height: 0.2.sh),
          Text(
            context.t.downloadWaitingMessage,
            style: context.textTheme.labelSmall,
          ),
          24.gapH,
          const AzkarSlider(),
          // CustomButton(onPressed: notifier.download, text: 'Download'),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(controller.downlaodProgressPercentage,
                  style: context.textTheme.labelSmall),
              // Text(controller.downloadStatus.toString(),
              //     style: context.textTheme.labelSmall),
            ],
          ),
          4.gapH,
          DownloadProgressBar(progress: controller.downloadProgressIntOrNull),
          24.gapH,
          SvgIcon(
            Assets.icons.quranText.path,
            size: 70.r,
            color: context.colorScheme.onSurface.withOpacity(0.8),
          ),
        ],
      ),
    );
  }
}
