import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/controllers/wallet_controller.dart';
import 'package:app/core/services/wallet_service.dart';

final walletServiceProvider = Provider<WalletService>(
  (ref) => WalletService.instance,
);

final walletControllerProvider =
    AsyncNotifierProvider.autoDispose<WalletController, void>(
      () => WalletController(),
    );
