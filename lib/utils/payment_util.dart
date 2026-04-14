import 'package:intl/intl.dart';

import 'package:app/models/payment_card.dart';

class PaymentUtil {
  static String getLast4Digits(String cardNumber) {
    return cardNumber.substring(cardNumber.length - 4);
  }

  static CardType getCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return CardType.visa;
    } else if (cardNumber.startsWith('5')) {
      return CardType.mastercard;
    } else if (cardNumber.startsWith('3')) {
      return CardType.rupay;
    } else {
      return CardType.other;
    }
  }

  static String generatePaymentMethodId(String cardNumber) {
    final last4 = getLast4Digits(cardNumber);
    final cardType = getCardType(cardNumber);

    return 'pm_${cardType.name}_$last4';
  }

  static String extractMonth(String expiryDate) {
    return expiryDate.substring(0, 2);
  }

  static String extractYear(String expiryDate) {
    return expiryDate.substring(3, 5);
  }

  static String formatAmount(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}
