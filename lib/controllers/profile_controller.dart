import 'dart:io';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/models/user_model.dart';
import 'package:app/utils/firebase_utils.dart';
import 'package:app/providers/firebase_providers.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/profile_providers.dart';

class ProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> updateUserProfile(UserModel user, {File? newProfile}) async {
    state = const AsyncValue.loading();

    if (newProfile != null) {
      final profilePicPath = await ref
          .read(firebaseStorageServiceProvider)
          .uploadImage(newProfile);

      user = user.copyWith(profilePicPath: profilePicPath);
    }

    if (user.profilePicPath != null && newProfile == null) {
      final extractedPath = FirebaseUtils.extractFirebaseStoragePath(
        user.profilePicPath!,
      );
      user = user.copyWith(profilePicPath: extractedPath);
    }

    final result = await ref
        .read(profileServiceProvider)
        .updateUserProfile(user);

    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (right) async {
        if (newProfile != null || user.profilePicPath != null) {
          final profilePicUrl = await ref
              .read(firebaseStorageServiceProvider)
              .getImageUrlFromPath(user.profilePicPath!);

          user = user.copyWith(profilePicPath: profilePicUrl);
        }

        ref.read(authStateChangesProvider.notifier).updateUserData(user);
        state = AsyncValue.data(right);
      },
    );
  }
}
