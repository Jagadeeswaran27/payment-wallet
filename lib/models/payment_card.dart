enum CardType { visa, mastercard, rupay, other }

class PaymentCard {
  String id;
  String paymentMethodId;
  CardType cardType;
  String last4;
  String cardHolderName;
  String expiryMonth;
  String expiryYear;
  bool isDefault;
  String createdAt;

  PaymentCard({
    required this.id,
    required this.paymentMethodId,
    required this.cardType,
    required this.last4,
    required this.cardHolderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
    required this.createdAt,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'],
      paymentMethodId: json['paymentMethodId'],
      cardType: CardType.values.firstWhere((e) => e.name == json['cardType']),
      last4: json['last4'],
      cardHolderName: json['cardHolderName'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      isDefault: json['isDefault'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentMethodId': paymentMethodId,
      'cardType': cardType.name,
      'last4': last4,
      'cardHolderName': cardHolderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
      'createdAt': createdAt,
    };
  }

  PaymentCard copyWith({
    String? id,
    String? paymentMethodId,
    CardType? cardType,
    String? last4,
    String? cardHolderName,
    String? expiryMonth,
    String? expiryYear,
    bool? isDefault,
    String? createdAt,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      cardType: cardType ?? this.cardType,
      last4: last4 ?? this.last4,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
