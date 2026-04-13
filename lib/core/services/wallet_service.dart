import 'package:fpdart/fpdart.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app/models/errors/failure.dart';
import 'package:app/utils/payment_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WalletService {
  WalletService._();

  static final WalletService instance = WalletService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const double dailyTopUpLimit = 50000.0;

  /// Returns today's date string in IST (UTC+5:30) as 'YYYY-MM-DD'.
  String _getTodayDateKeyIST() {
    final nowUtc = DateTime.now().toUtc();
    final nowIST = nowUtc.add(const Duration(hours: 5, minutes: 30));
    return '${nowIST.year}-${nowIST.month.toString().padLeft(2, '0')}-${nowIST.day.toString().padLeft(2, '0')}';
  }

  /// Returns the remaining daily top-up amount for the current user.
  Future<Either<Failure, double>> getDailyTopUpRemaining() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        return left(const Failure('User not found'));
      }

      final todayKey = _getTodayDateKeyIST();
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_top_ups')
          .doc(todayKey);

      final snapshot = await docRef.get();
      final currentTotal =
          snapshot.exists ? (snapshot.data()?['totalAmount'] ?? 0.0) as num : 0.0;

      final remaining = dailyTopUpLimit - currentTotal.toDouble();
      return right(remaining < 0 ? 0.0 : remaining);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Adds balance to the wallet with a daily limit of ₹50,000.
  ///
  /// Uses a Firestore transaction to atomically check the daily total
  /// and update both the daily tracker and wallet balance, ensuring
  /// cross-device safety.
  Future<Either<Failure, void>> addWalletBalance(double amount) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        return left(const Failure('User not found'));
      }

      final userId = user.uid;
      final todayKey = _getTodayDateKeyIST();

      final userDocRef = _firestore.collection('users').doc(userId);
      final dailyTopUpDocRef = userDocRef
          .collection('daily_top_ups')
          .doc(todayKey);

      // Atomic Firestore transaction: read daily total → validate → write
      final result = await _firestore.runTransaction<Either<Failure, void>>(
        (transaction) async {
          final dailySnapshot = await transaction.get(dailyTopUpDocRef);

          final currentTotal = dailySnapshot.exists
              ? (dailySnapshot.data()?['totalAmount'] ?? 0.0) as num
              : 0.0;

          final newTotal = currentTotal.toDouble() + amount;

          if (newTotal > dailyTopUpLimit) {
            final remaining = dailyTopUpLimit - currentTotal.toDouble();
            final formattedRemaining = PaymentUtil.formatAmount(
              remaining < 0 ? 0 : remaining,
            );
            return left(Failure(
              'Daily limit exceeded. You can add up to $formattedRemaining more today.',
            ));
          }

          // Update daily top-up tracker
          transaction.set(dailyTopUpDocRef, {'totalAmount': newTotal});

          // Increment wallet balance
          transaction.update(userDocRef, {
            'walletBalance': FieldValue.increment(amount),
          });

          return right(null);
        },
      );

      return result;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
