import 'dart:io';
import 'package:app/core/config/app_logger.dart';
import 'package:app/models/errors/failure.dart';
import 'package:app/providers/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KycServices {
  KycServices._();
  static final KycServices instance = KycServices._();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Either<Failure, void>> updateKycStatus({
    required WidgetRef ref,
    required String uid,
    required File image1,
    required File image2,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({'kycStatus': true});
      await ref.read(firebaseStorageServiceProvider).uploadKycImage(image1);
      await ref.read(firebaseStorageServiceProvider).uploadKycImage(image2);
      return Right(null);
    } catch (e) {
      AppLogger.e(e.toString());
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> getKycStatus({
    required WidgetRef ref,
    required String uid,
  }) async {
    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      final data = snapshot.data();
      if (data != null && data['kycStatus'] != null) {
        return Right(data['kycStatus']);
      }
      return Right(false);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
