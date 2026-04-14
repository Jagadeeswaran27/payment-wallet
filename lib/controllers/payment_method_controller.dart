import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/models/payment_card.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/payment_method_providers.dart';
import 'package:app/utils/payment_util.dart';
import 'package:fpdart/fpdart.dart';

class PaymentMethodController extends AsyncNotifier<List<PaymentCard>> {
  @override
  Future<List<PaymentCard>> build() async {
    state = AsyncValue.loading();

    final result = await ref
        .read(paymentMethodServiceProvider)
        .getPaymentCardDetails();

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return [];
      },
      (paymentCards) {
        state = AsyncValue.data(paymentCards);
        return paymentCards;
      },
    );
  }

  Future<void> savePaymentCardDetails(PaymentCard paymentCard) async {
    state = AsyncValue.loading();

    final result = await ref
        .read(paymentMethodServiceProvider)
        .savePaymentCardDetails(paymentCard);

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => AsyncValue.data([...state.value!, paymentCard]),
    );
  }

  Future<void> addCard({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardHolderName,
  }) async {
    final user = ref.read(authStateChangesProvider).value;

    if (user == null) {
      state = AsyncValue.error('User not found', StackTrace.current);
      return;
    }

    if (user.kycStatus != true) {
      state = AsyncValue.error(
        'Please complete KYC verification to add payment cards',
        StackTrace.current,
      );
      return;
    }

    final paymentMethodId = PaymentUtil.generatePaymentMethodId(cardNumber);
    final cardType = PaymentUtil.getCardType(cardNumber);
    final last4 = PaymentUtil.getLast4Digits(cardNumber);
    final expiryMonth = PaymentUtil.extractMonth(expiryDate);
    final expiryYear = PaymentUtil.extractYear(expiryDate);

    final paymentCard = PaymentCard(
      id: paymentMethodId,
      paymentMethodId: paymentMethodId,
      cardType: cardType,
      last4: last4,
      cardHolderName: cardHolderName,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      isDefault: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    await savePaymentCardDetails(paymentCard);
  }

  Future<void> deletePaymentCardDetails(String cardId) async {
    final result = await ref
        .read(paymentMethodServiceProvider)
        .deletePaymentCardDetails(cardId);

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) {
        final updatedStateValue = state.value!
            .filter((card) => card.id != cardId)
            .toList();
        return AsyncValue.data(updatedStateValue);
      },
    );
  }

  Future<void> setDefaultPaymentCard(String newDefaultCardId) async {
    final stateValue = state.value!;

    final oldDefaultCard = stateValue
        .where((card) => card.isDefault)
        .firstOrNull;

    final result = await ref
        .read(paymentMethodServiceProvider)
        .modifyDefaultPaymentCard(newDefaultCardId, oldDefaultCard?.id);

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) {
        final updatedStateValue = state.value!
            .map(
              (card) => card.id == newDefaultCardId
                  ? card.copyWith(isDefault: true)
                  : card.copyWith(isDefault: false),
            )
            .toList();
        return AsyncValue.data(updatedStateValue);
      },
    );
  }
}
