import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/services/pin_service.dart';
import 'package:app/providers/pin_providers.dart';
import 'package:app/providers/auth_provider.dart';

class PinController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<String?> setPin(String pin) async {
    state = const AsyncValue.loading();
    
    final pinHash = PinService.hashPin(pin);
    final result = await ref.read(pinServiceProvider).setPin(pinHash);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (success) {
        ref.read(authStateChangesProvider.notifier).updatePinHash(pinHash);
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }

  Future<bool> verifyPin(String pin) async {
    final pinHash = PinService.hashPin(pin);
    final result = await ref.read(pinServiceProvider).verifyPin(pinHash);

    return result.fold(
      (failure) => false,
      (isMatch) => isMatch,
    );
  }
}
