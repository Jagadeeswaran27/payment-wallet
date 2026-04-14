import 'package:fpdart/fpdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app/models/errors/failure.dart';
import 'package:app/models/payment_card.dart';

class PaymentMethodService {
  PaymentMethodService._();

  static final PaymentMethodService instance = PaymentMethodService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Either<Failure, List<PaymentCard>>> getPaymentCardDetails() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        return left(const Failure('User is not authenticated'));
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('payment_cards')
          .get();

      if (snapshot.docs.isEmpty) {
        return right([]);
      }

      final paymentCard = snapshot.docs
          .map((doc) => PaymentCard.fromJson(doc.data()))
          .toList();

      return right(paymentCard);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deletePaymentCardDetails(String cardId) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        return left(const Failure('User is not authenticated'));
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('payment_cards')
          .doc(cardId)
          .delete();

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> modifyDefaultPaymentCard(
    String newDefaultPaymentCardId,
    String? oldDefaultPaymentCardId,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        return left(const Failure('User is not authenticated'));
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('payment_cards')
          .doc(newDefaultPaymentCardId)
          .update({'isDefault': true});

      if (oldDefaultPaymentCardId != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('payment_cards')
            .doc(oldDefaultPaymentCardId)
            .update({'isDefault': false});
      }

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> savePaymentCardDetails(
    PaymentCard paymentCard,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        return left(const Failure('User is not authenticated'));
      }

      final dbPaymentCard = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('payment_cards')
          .doc(paymentCard.id)
          .get();

      if (dbPaymentCard.exists) {
        return left(const Failure('Payment card already exists'));
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('payment_cards')
          .doc(paymentCard.id)
          .set(paymentCard.toJson());

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
