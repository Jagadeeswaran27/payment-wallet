import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/models/transaction_model.dart';
import 'package:app/controllers/transaction_controller.dart';
import 'package:app/core/services/transaction_service.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService.instance;
});

final transactionControllerProvider =
    AsyncNotifierProvider.autoDispose<
      TransactionController,
      List<TransactionModel>
    >(() => TransactionController());
