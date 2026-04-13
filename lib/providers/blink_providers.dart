import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/services/blink_service.dart';
import 'package:app/controllers/blink_controller.dart';
import 'package:app/models/blink_card_model.dart';

final blinkServiceProvider = Provider<BlinkService>((ref) {
  return BlinkService.instance;
});

final blinkCardsProvider = StreamProvider.autoDispose<List<BlinkCardModel>>((ref) {
  final service = ref.watch(blinkServiceProvider);
  return service.getBlinkCardsStream();
});

final blinkControllerProvider =
    AsyncNotifierProvider<BlinkController, void>(BlinkController.new);
