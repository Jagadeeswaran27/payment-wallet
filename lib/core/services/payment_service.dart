import 'package:fpdart/fpdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app/models/errors/failure.dart';
import 'package:app/utils/payment_util.dart';

class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const double dailyBankPaymentLimit = 50000.0;

  /// Returns today's date string in IST (UTC+5:30) as 'YYYY-MM-DD'.
  String _getTodayDateKeyIST() {
    final nowUtc = DateTime.now().toUtc();
    final nowIST = nowUtc.add(const Duration(hours: 5, minutes: 30));
    return '${nowIST.year}-${nowIST.month.toString().padLeft(2, '0')}-${nowIST.day.toString().padLeft(2, '0')}';
  }

  /// Returns the remaining daily bank payment amount for the current user.
  Future<Either<Failure, double>> getDailyBankPaymentRemaining() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return left(const Failure('User not found'));
      }

      final todayKey = _getTodayDateKeyIST();
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_bank_payments')
          .doc(todayKey);

      final snapshot = await docRef.get();
      final currentTotal =
          snapshot.exists ? (snapshot.data()?['totalAmount'] ?? 0.0) as num : 0.0;

      final remaining = dailyBankPaymentLimit - currentTotal.toDouble();
      return right(remaining < 0 ? 0.0 : remaining);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Evaluates limit constraints and increments bank payment totals if approved.
  Future<Either<Failure, void>> processBankPayment(double amount) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return left(const Failure('User not found'));
      }

      final userId = user.uid;
      final todayKey = _getTodayDateKeyIST();

      final dailyBankPaymentDocRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_bank_payments')
          .doc(todayKey);

      final result = await _firestore.runTransaction<Either<Failure, void>>(
        (transaction) async {
          final dailySnapshot = await transaction.get(dailyBankPaymentDocRef);

          final currentTotal = dailySnapshot.exists
              ? (dailySnapshot.data()?['totalAmount'] ?? 0.0) as num
              : 0.0;

          final newTotal = currentTotal.toDouble() + amount;

          if (newTotal > dailyBankPaymentLimit) {
            final remaining = dailyBankPaymentLimit - currentTotal.toDouble();
            final formattedRemaining = PaymentUtil.formatAmount(
              remaining < 0 ? 0 : remaining,
            );
            return left(Failure(
              'Daily limit exceeded. You can pay up to $formattedRemaining more from your bank account today.',
            ));
          }

          transaction.set(dailyBankPaymentDocRef, {'totalAmount': newTotal});
          return right(null);
        },
      );

      return result;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> sendMoney({required double amount}) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return left(Failure('User not found'));
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        return left(Failure('User not found'));
      }

      final userData = doc.data()!;
      final balance = userData['walletBalance'] as double;
      if (balance < amount) {
        return left(Failure('Insufficient balance'));
      }

      await _firestore.collection('users').doc(user.uid).update({
        'walletBalance': balance - amount,
      });

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
