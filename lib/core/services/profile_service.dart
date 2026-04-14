import 'package:fpdart/fpdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app/models/errors/failure.dart';
import 'package:app/models/user_model.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Either<Failure, void>> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
