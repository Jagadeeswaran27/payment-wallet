import 'package:app/controllers/onboarding_controller.dart';
import 'package:app/core/services/onboarding_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingServiceProvider = Provider<OnboardingService>(
  (ref) => OnboardingService.instance,
);

final onboardingControllerProvider =
    AsyncNotifierProvider.autoDispose<OnboardingController, void>(
      OnboardingController.new,
    );
