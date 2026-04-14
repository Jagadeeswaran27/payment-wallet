import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/controllers/payment_controller.dart';
import 'package:app/core/services/payment_service.dart';

final paymentServiceProvider = Provider<PaymentService>(
  (ref) => PaymentService.instance,
);

final paymentControllerProvider =
    AsyncNotifierProvider<PaymentController, String?>(
      () => PaymentController(),
    );
