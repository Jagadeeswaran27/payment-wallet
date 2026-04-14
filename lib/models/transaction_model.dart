import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app/models/enums/payment_type.dart';

// Debit: Reduction in balance
// Credit: Increase in balance

enum TransactionType { credit, debit }

class TransactionModel {
  final String id;
  final double amount;
  final PaymentType paymentType;
  final TransactionType transactionType;
  final String? destinationUpiId;
  final String? sourceCardId;
  final Timestamp? timestamp;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.paymentType,
    this.destinationUpiId,
    this.sourceCardId,
    this.transactionType = TransactionType.debit,
    this.timestamp,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      paymentType: PaymentType.values.firstWhere(
        (e) => e.name == map['paymentType'],
      ),
      destinationUpiId: map['destinationUpiId'],
      sourceCardId: map['sourceCardId'],
      transactionType: TransactionType.values.firstWhere(
        (e) => e.name == map['transactionType'],
      ),
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'paymentType': paymentType.name,
      'destinationUpiId': destinationUpiId,
      'sourceCardId': sourceCardId,
      'transactionType': transactionType.name,
      'timestamp': timestamp,
    };
  }

  TransactionModel copyWith({
    String? id,
    double? amount,
    PaymentType? paymentType,
    String? destinationUpiId,
    String? sourceCardId,
    TransactionType? transactionType,
    Timestamp? timestamp,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      paymentType: paymentType ?? this.paymentType,
      destinationUpiId: destinationUpiId ?? this.destinationUpiId,
      sourceCardId: sourceCardId ?? this.sourceCardId,
      transactionType: transactionType ?? this.transactionType,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
