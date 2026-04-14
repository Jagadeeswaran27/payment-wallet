import 'package:app/providers/firebase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/controllers/auth_controller.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:app/models/user_model.dart';
import 'package:app/states/auth_state.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService.instance,
);

final authControllerProvider =
    AsyncNotifierProvider<AuthController, PhoneAuthState>(AuthController.new);

final authStateChangesProvider =
    StreamNotifierProvider.autoDispose<AuthUserStateNotifier, UserModel?>(() {
      return AuthUserStateNotifier();
    });

class AuthUserStateNotifier extends StreamNotifier<UserModel?> {
  @override
  Stream<UserModel?> build() {
    final authService = ref.watch(authServiceProvider);
    final storageService = ref.read(firebaseStorageServiceProvider);

    return authService.authStateChanges.asyncMap((user) async {
      if (user == null) return null;

      final profilePicPath = user.profilePicPath;

      if (profilePicPath == null) {
        return user;
      }

      final profilePicUrl = await storageService.getImageUrlFromPath(
        profilePicPath,
      );

      return user.copyWith(profilePicPath: profilePicUrl);
    });
  }

  void updateUserData(UserModel newUser) {
    state = AsyncValue.data(newUser);
  }

  void updateUserWalletBalance(double amount) {
    state = AsyncValue.data(
      state.value?.copyWith(walletBalance: state.value!.walletBalance + amount),
    );
  }

  void reduceUserWalletBalance(double amount) {
    state = AsyncValue.data(
      state.value?.copyWith(walletBalance: state.value!.walletBalance - amount),
    );
  }

  void updateKycStatus(bool status) {
    state = AsyncValue.data(state.value?.copyWith(kycStatus: status));
  }

  void updatePinHash(String pinHash) {
    state = AsyncValue.data(state.value?.copyWith(pinHash: pinHash));
  }
}
