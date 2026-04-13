import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/core/services/pin_service.dart';
import 'package:app/controllers/pin_controller.dart';

final pinServiceProvider = Provider<PinService>((ref) {
  return PinService.instance;
});

final pinControllerProvider =
    AsyncNotifierProvider<PinController, void>(PinController.new);
