import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/providers/transaction_providers.dart';
import 'package:app/models/transaction_model.dart';
import 'package:app/models/enums/payment_type.dart';
import 'package:app/providers/payment_providers.dart';
import 'package:app/providers/auth_provider.dart';

class PaymentController extends AsyncNotifier<String?> {
  @override
  String? build() {
    return null;
  }

  Future<double> getDailyBankPaymentRemaining() async {
    final result = await ref
        .read(paymentServiceProvider)
        .getDailyBankPaymentRemaining();

    return result.fold(
      (failure) => 0.0,
      (remaining) => remaining,
    );
  }

  Future<void> storeUpiId({required String upiId}) async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(upiId);
  }

  Future<void> sendMoney({
    required double amount,
    required PaymentType paymentType,
    String? sourceCardId,
  }) async {
    state = const AsyncValue.loading();

    if (paymentType == PaymentType.wallet) {
      final result = await ref
          .read(paymentServiceProvider)
          .sendMoney(amount: amount);

      result.fold(
        (failure) =>
            state = AsyncValue.error(failure.message, StackTrace.current),
        (_) async {
          ref
              .read(authStateChangesProvider.notifier)
              .reduceUserWalletBalance(amount);

          final transactionResult = await ref
              .read(transactionServiceProvider)
              .addTransaction(
                transaction: TransactionModel(
                  id: '',
                  amount: amount,
                  paymentType: PaymentType.wallet,
                  destinationUpiId: state.value!,
                ),
              );

          transactionResult.fold(
            (failure) =>
                state = AsyncValue.error(failure.message, StackTrace.current),
            (transaction) {
              ref
                  .read(transactionControllerProvider.notifier)
                  .updateTransaction(transaction);
              state = AsyncValue.data(null);
            },
          );
        },
      );
    } else {
      // Process bank payment checking daily limits via transaction
      final bankPaymentResult = await ref
          .read(paymentServiceProvider)
          .processBankPayment(amount);
          
      bankPaymentResult.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (success) async {
          final upiId = state.value;

          final transactionResult = await ref
              .read(transactionServiceProvider)
              .addTransaction(
                transaction: TransactionModel(
                  id: '',
                  amount: amount,
                  paymentType: PaymentType.card,
                  destinationUpiId: upiId,
                  sourceCardId: sourceCardId,
                ),
              );

          transactionResult.fold(
            (failure) =>
                state = AsyncValue.error(failure.message, StackTrace.current),
            (transaction) {
              ref
                  .read(transactionControllerProvider.notifier)
                  .updateTransaction(transaction);
              state = AsyncValue.data(upiId);
            },
          );
        },
      );
    }
  }
}
