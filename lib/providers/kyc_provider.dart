import 'package:app/controllers/kyc_controller.dart';
import 'package:app/core/services/kyc_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final kycProvider = Provider<KycServices>((ref) => KycServices.instance);

final kycControllerProvider =
    AsyncNotifierProvider.autoDispose<KycController, void>(KycController.new);
