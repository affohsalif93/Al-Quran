import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/pages/home/home_screen.dart';
import 'package:quran/pages/onboarding/download/download_screen.dart';
import 'package:quran/pages/onboarding/onboarding_screen.dart';
import 'package:quran/pages/onboarding/widgets/select_books.dart';
import 'package:quran/pages/settings/settings_screen.dart';
import 'package:quran/router/custom_go_route.dart';
import 'package:quran/router/route_utils.dart';
import 'package:quran/router/routes.dart';

final routeInformationProvider =
    ChangeNotifierProvider<GoRouteInformationProvider>((ref) {
  final router = ref.watch(goRouterProvider);
  return router.routeInformationProvider;
});

final currentRouteProvider = Provider<String>((ref) {
  return ref.watch(routeInformationProvider).value.uri.pathSegments.first;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: routerNotifier,
    routes: routerNotifier.routes,
    redirect: routerNotifier.redirect,
  );
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    init();
  }
  final Ref ref;
  bool get isLogged {
    return false;
    // return ref.read(tokenControllerProvider) != null;
  }

  void init() {
    // ref.listen(initialRouteProvider, (_, __) {
    //   notifyListeners();
    // });
  }

  FutureOr<String?> redirect(BuildContext context, GoRouterState state) async {
    return RouteUtils.redirect(state: state, ref: ref);
  }

  final List<RouteBase> routes = [
    // home
    CustomGoRoute(
      path: '/home',
      name: Routes.home.name,
      page: HomeScreen(),
      routes: [
        CustomGoRoute(
          path: 'settings',
          name: Routes.settings.name,
          page: const SettingsScreen(),
        ),
      ],
    ),

    // onboarding
    CustomGoRoute(
      path: '/onboarding',
      name: Routes.onboarding.name,
      page: const OnboardingScreen(),
      routes: [
        // choose riwayah
        CustomGoRoute(
          path: 'choose-riwayah',
          name: Routes.chooseRiwayah.name,
          page: const ChooseRiwayahScreen(),
        ),
      ],
    ),

    // download
    CustomGoRoute(
      path: '/download',
      name: Routes.download.name,
      page: const DownloadScreen(),
    ),
  ];
}
