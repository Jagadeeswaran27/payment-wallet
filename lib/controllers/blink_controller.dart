import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/blink_card_model.dart';
import 'package:app/providers/blink_providers.dart';

class BlinkController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<String?> addCard(BlinkCardModel card) async {
    state = const AsyncValue.loading();
    final result = await ref.read(blinkServiceProvider).addBlinkCard(card);
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }

  Future<String?> updateCard(BlinkCardModel card) async {
    state = const AsyncValue.loading();
    final result = await ref.read(blinkServiceProvider).updateBlinkCard(card);
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }

  Future<String?> deleteCard(String id) async {
    state = const AsyncValue.loading();
    final result = await ref.read(blinkServiceProvider).deleteBlinkCard(id);
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }
}
