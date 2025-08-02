import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:quran/assets/assets.gen.dart';
import 'package:quran/core/extensions/context_extensions.dart';
import 'package:quran/core/extensions/screen_utils_extensions.dart';
import 'package:quran/i18n/strings.g.dart';
import 'package:quran/router/routes.dart';
import 'package:quran/views/settings/choose_locale_dialog.dart';
import 'package:quran/views/settings/choose_theme_dialog.dart';
import 'package:quran/views/splash/azkar.dart';
import 'package:quran/views/widgets/custom_button.dart';
import 'package:quran/views/widgets/custom_scaffold.dart';
import 'package:quran/views/widgets/scrollable_column.dart';
import 'package:quran/views/widgets/svg_icon.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.goNamed(Routes.home.name);

    return CustomScaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: ScrollableColumn(
        constraintMinHeight: true,
        crossAxisAlignment: CrossAxisAlignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 88.h),
        children: [
          const Spacer(),
          SvgIcon(Assets.icons.quranText.path, size: 170.r, color: context.colorScheme.onSurface),
          const Spacer(),
          Align(alignment: AlignmentDirectional.center, child: const AzkarSlider()),
          const Spacer(),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Symbols.dark_mode),
                  onTap: () => context.customWidgetDialog(const ChooseThemeDialog()),
                  title: Text(context.t.themeMode),
                  trailing: Text(context.themeAsText),
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                // language selection
                ListTile(
                  leading: const Icon(Symbols.language),
                  onTap: () => context.customWidgetDialog(const ChooseLocaleDialog()),
                  title: Text(context.t.language),
                  subtitle: Text(context.t.languageOtherLanguage),
                  trailing: Text(context.languageAsText),
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                12.gapH,
                CustomButton(
                  text: context.t.next,
                  onPressed: () => context.goNamed(Routes.home.name),
                  height: 40,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
