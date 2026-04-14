import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/providers/transaction_providers.dart';
import 'package:app/models/transaction_model.dart';

class TransactionController extends AsyncNotifier<List<TransactionModel>> {
  @override
  Future<List<TransactionModel>> build() async {
    state = const AsyncValue.loading();
    final result = await ref.read(transactionServiceProvider).getTransactions();
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return [];
      },
      (transactions) {
        state = AsyncValue.data(transactions);
        return transactions;
      },
    );
  }

  // TODO: This should be an trigger from firebase cloud functions. Change later

  Future<void> updateTransaction(TransactionModel newTransaction) async {
    state = const AsyncValue.loading();
    if (state.value != null) {
      state = AsyncValue.data([...state.value!, newTransaction]);
    }
  }

  // Future<void> addTransaction({
  //   required TransactionModel newTransaction,
  // }) async {
  //   state = const AsyncValue.loading();

  //   final result = await ref
  //       .read(transactionServiceProvider)
  //       .addTransaction(transaction: newTransaction);

  //   result.fold(
  //     (failure) =>
  //         state = AsyncValue.error(failure.message, StackTrace.current),
  //     (_) => state = AsyncValue.data([...state.value!, newTransaction]),
  //   );
  // }
}
