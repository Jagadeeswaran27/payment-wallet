import 'dart:async';
import 'dart:io';

import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/kyc_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KycController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> updateKycStatus({
    required WidgetRef ref,
    required String uid,
    required File image1,
    required File image2,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(kycProvider)
        .updateKycStatus(ref: ref, uid: uid, image1: image1, image2: image2);
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), (
      sucess,
    ) {
      ref.read(authStateChangesProvider.notifier).updateKycStatus(true);
      return AsyncData(sucess);
    });
  }
}
