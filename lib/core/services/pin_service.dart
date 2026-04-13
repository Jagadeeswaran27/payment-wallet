import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:app/models/errors/failure.dart';

class PinService {
  PinService._();

  static final PinService instance = PinService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Either<Failure, void>> setPin(String pinHash) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return left(const Failure('User not found'));
      }

      await _firestore.collection('users').doc(user.uid).update({
        'pinHash': pinHash,
      });

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> verifyPin(String pinHash) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return left(const Failure('User not found'));
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        return left(const Failure('User record not found'));
      }

      final storedHash = doc.data()?['pinHash'] as String?;
      if (storedHash == null) {
        return left(const Failure('PIN not set'));
      }

      return right(storedHash == pinHash);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
