import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/models/user_model.dart';
import 'package:app/router/app_routes.dart';

class NavigationService {
  NavigationService._();
  static final NavigationService instance = NavigationService._();
  static final List<String> _authRoutes = [
    AppRoutes.welcome.path,
    AppRoutes.phoneAuth.path,
    AppRoutes.otp.path,
  ];

  String? getRedirectedPath(
    AsyncValue<UserModel?> userState,
    String currentPath,
  ) {
    if (userState.isLoading) {
      return AppRoutes.loading.path;
    }

    if (userState.value == null) {
      if (_authRoutes.contains(currentPath)) {
        return null;
      }
      return AppRoutes.welcome.path;
    } else {
      if (userState.value!.isOnboardCompleted) {
        if (_authRoutes.contains(currentPath) ||
            currentPath == AppRoutes.loading.path) {
          return AppRoutes.home.path;
        }
        return null;
      }
      return AppRoutes.onboarding.path;
    }
  }
}
