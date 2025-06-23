import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:quran/common_widgets/async_value_builder.dart';
import 'package:quran/common_widgets/custom_app_bar.dart';
import 'package:quran/common_widgets/custom_button.dart';
import 'package:quran/common_widgets/custom_loading.dart';
import 'package:quran/common_widgets/custom_scaffold.dart';
import 'package:quran/extensions/context_extensions.dart';
import 'package:quran/extensions/screen_utils_extensions.dart';
import 'package:quran/i18n/strings.g.dart';
import '../onboarding_controller.dart';
import 'book_select.dart';

class ChooseRiwayahScreen extends ConsumerWidget {
  const ChooseRiwayahScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(onboardingControllerProvider);
    final notifier = ref.read(onboardingControllerProvider.notifier);

    return CustomScaffold(
      appBar: CustomAppBar(
        title: context.t.chooseRiwayah,
      ),
      body: Column(
        children: [
          Expanded(
            child: AsyncValueBuilder(
              value: controller.riwayahListAsync,
              data: (riwayahList) {
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  itemCount: riwayahList.length,
                  separatorBuilder: (_, __) => 8.gapH,
                  itemBuilder: (BuildContext context, int index) {
                    final riwayah = riwayahList[index];
                    return RiwayahSelect(
                      riwayah: riwayah,
                      isSelected:
                          riwayah.fileName == controller.selectedRiwayahName,
                      onSelected: () =>
                          notifier.setSelectedRiwayah(riwayah.fileName),
                    );
                  },
                );
              },
              loading: () => const Center(child: CustomLoading()),
              onRefresh: notifier.fetchRiwayahList,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              border: Border(top: BorderSide(color: context.colors.stroke)),
            ),
            child: CustomButton(
              text: context.t.download,
              onPressed: controller.isSelectedRiwayah
                  ? notifier.startDownloading
                  : null,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}
