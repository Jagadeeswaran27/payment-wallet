import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/models/enums/payment_type.dart';
import 'package:app/models/transaction_model.dart';
import 'package:app/providers/transaction_providers.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/walllet_providers.dart';

class WalletController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  /// Returns how much the user can still add to their wallet today.
  Future<double> getDailyTopUpRemaining() async {
    final result = await ref
        .read(walletServiceProvider)
        .getDailyTopUpRemaining();

    return result.fold(
      (failure) => 0.0,
      (remaining) => remaining,
    );
  }

  Future<void> addWalletBalance({
    required double amount,
    required String sourceCardId,
  }) async {
    state = AsyncValue.loading();

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) {
      state = AsyncValue.error('User not found', StackTrace.current);
      return;
    }

    if (user.kycStatus != true) {
      state = AsyncValue.error(
        'Please complete KYC verification to add wallet balance',
        StackTrace.current,
      );
      return;
    }

    final result = await ref
        .read(walletServiceProvider)
        .addWalletBalance(amount);

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (success) async {
        ref
            .read(authStateChangesProvider.notifier)
            .updateUserWalletBalance(amount);

        final transaction = TransactionModel(
          id: '',
          amount: amount,
          paymentType: PaymentType.wallet,
          transactionType: TransactionType.credit,
          sourceCardId: sourceCardId,
        );

        final transactionResult = await ref
            .read(transactionServiceProvider)
            .addTransaction(transaction: transaction);

        transactionResult.fold(
          (failure) =>
              state = AsyncValue.error(failure.message, StackTrace.current),
          (transaction) {
            ref
                .read(transactionControllerProvider.notifier)
                .updateTransaction(transaction);
            state = AsyncValue.data(success);
          },
        );
      },
    );
  }
}

