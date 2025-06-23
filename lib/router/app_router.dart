import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quran/router/custom_go_route.dart';
import 'package:quran/router/route_utils.dart';
import 'package:quran/router/routes.dart';
import 'package:quran/views/home/home_screen.dart';
import 'package:quran/views/splash/splash_screen.dart';

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
    initialLocation: '/azkar',
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
    CustomGoRoute(
      path: '/azkar',
      name: Routes.azkar.name,
      page: SplashScreen(),
    ),

    CustomGoRoute(
      path: '/home',
      name: Routes.home.name,
      page: const HomeScreen(),
    ),
  ];
}
