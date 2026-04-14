import 'package:fpdart/fpdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app/models/errors/failure.dart';
import 'package:app/models/transaction_model.dart';

class TransactionService {
  TransactionService._();

  static final TransactionService instance = TransactionService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Either<Failure, List<TransactionModel>>> getTransactions() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        return left(Failure('User not found'));
      }

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .get();

      return right(
        doc.docs.map((e) => TransactionModel.fromMap(e.data())).toList(),
      );
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // TODO: This should be an trigger from firebase cloud functions. Change later

  Future<Either<Failure, TransactionModel>> addTransaction({
    required TransactionModel transaction,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        return left(Failure('User not found'));
      }

      final doc = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc();

      transaction = transaction.copyWith(
        id: doc.id,
        timestamp: Timestamp.now(),
      );

      await doc.set(transaction.toMap());

      return right(transaction);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
