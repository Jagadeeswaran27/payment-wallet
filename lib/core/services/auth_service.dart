import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app/models/errors/failure.dart';
import 'package:app/models/phone_auth_result.dart';
import 'package:app/models/user_model.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<PhoneAuthResult> verifyPhoneNumber({
    required String phoneNumber,
    int? resendToken,
  }) {
    final controller = StreamController<PhoneAuthResult>.broadcast();

    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken,
      codeSent: (verId, token) {
        controller.add(CodeSent(verId, token));
        controller.close();
      },
      verificationFailed: (e) {
        controller.add(PhoneAuthError(e.message ?? "Verification Failed"));
        controller.close();
      },
      verificationCompleted: (credential) {
        controller.add(PhoneAuthCompleted(credential));
        controller.close();
      },
      codeAutoRetrievalTimeout: (id) {
        controller.close();
      },
    );

    return controller.stream;
  }

  Future<Either<Failure, UserModel>> signInWithOtp({
    required String smsCode,
    required String verificationId,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user == null) {
        return Left(Failure('User not authenticated'));
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        final userModel = UserModel(
          uid: user.uid,
          phone: user.phoneNumber!,
          isOnboardCompleted: false,
          walletBalance: 0,
          address: null,
          email: null,
          name: null,
          state: null,
          profilePicPath: null,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        return Right(userModel);
      }

      return Right(UserModel.fromMap(userDoc.data() as Map<String, dynamic>));
    } on FirebaseAuthException catch (e) {
      return Left(Failure(e.message ?? "Verification Failed"));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      final result = await getCurrentUser();
      return result.fold((failure) => null, (user) => user);
    });
  }

  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Left(Failure('User not authenticated'));
      }
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        return Left(Failure('User not found'));
      }
      return Right(UserModel.fromMap(userDoc.data() as Map<String, dynamic>));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
