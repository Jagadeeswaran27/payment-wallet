import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/onboarding_providers.dart';

class OnboardingController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> saveOnboardingDetails({
    required String name,
    required String email,
    required String userState,
    required String address,
  }) async {
    state = const AsyncValue.loading();
    final authUserState = ref.read(authStateChangesProvider);

    if (authUserState.asData?.value == null) {
      state = AsyncValue.error('User not found', StackTrace.current);
      return;
    }

    final updatedUser = authUserState.asData!.value!.copyWith(
      name: name,
      email: email,
      state: userState,
      address: address,
      isOnboardCompleted: true,
    );

    final result = await ref
        .read(onboardingServiceProvider)
        .saveOnboardingDetails(updatedUser);

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (user) {
        ref.read(authStateChangesProvider.notifier).updateUserData(updatedUser);
        return AsyncValue.data(user);
      },
    );
  }
}
