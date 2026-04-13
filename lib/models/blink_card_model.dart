import 'package:cloud_firestore/cloud_firestore.dart';

class BlinkCardModel {
  final String id;
  final String name;
  final String receiverUpiId;
  final String sourceId; // 'wallet' or paymentCard's id
  final double amount;
  final Timestamp? createdAt;

  BlinkCardModel({
    required this.id,
    required this.name,
    required this.receiverUpiId,
    required this.sourceId,
    required this.amount,
    this.createdAt,
  });

  factory BlinkCardModel.fromMap(Map<String, dynamic> map, String docId) {
    return BlinkCardModel(
      id: docId,
      name: map['name'] ?? '',
      receiverUpiId: map['receiverUpiId'] ?? '',
      sourceId: map['sourceId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'receiverUpiId': receiverUpiId,
      'sourceId': sourceId,
      'amount': amount,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  BlinkCardModel copyWith({
    String? id,
    String? name,
    String? receiverUpiId,
    String? sourceId,
    double? amount,
    Timestamp? createdAt,
  }) {
    return BlinkCardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      receiverUpiId: receiverUpiId ?? this.receiverUpiId,
      sourceId: sourceId ?? this.sourceId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
