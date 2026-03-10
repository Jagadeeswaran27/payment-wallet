import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/router/app_routes.dart';
import 'package:app/screens/main_wrapper_screen.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/navigation_service_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final routerListenable = RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.welcome.path,
    refreshListenable: routerListenable,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapperScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [AppRoutes.home.route]),
          StatefulShellBranch(routes: [AppRoutes.wallet.route]),
          StatefulShellBranch(routes: [AppRoutes.cart.route]),
          StatefulShellBranch(routes: [AppRoutes.account.route]),
        ],
      ),
      AppRoutes.welcome.route,
      AppRoutes.phoneAuth.route,
      AppRoutes.otp.route,
      AppRoutes.onboarding.route,
      AppRoutes.loading.route,
      AppRoutes.addFundingSource.route,
      AppRoutes.addMoney.route,
      AppRoutes.sendMoney.route,
      AppRoutes.profile.route,
      AppRoutes.transactions.route,
      AppRoutes.kyc.route,
    ],
    redirect: (context, state) {
      final authUserState = ref.read(authStateChangesProvider);
      final navigationService = ref.read(navigationServiceProvider);
      return navigationService.getRedirectedPath(
        authUserState,
        state.matchedLocation,
      );
    },
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref ref;
  RouterNotifier(this.ref) {
    ref.listen(authStateChangesProvider, (_, _) {
      notifyListeners();
    });
  }
}
