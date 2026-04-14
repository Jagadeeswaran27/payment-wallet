import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:app/models/errors/failure.dart';
import 'package:app/models/blink_card_model.dart';

class BlinkService {
  BlinkService._();
  static final BlinkService instance = BlinkService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _getCollection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('blink_cards');
  }

  Stream<List<BlinkCardModel>> getBlinkCardsStream() {
    return _getCollection()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BlinkCardModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<Either<Failure, void>> addBlinkCard(BlinkCardModel card) async {
    try {
      await _getCollection().add(card.toMap());
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateBlinkCard(BlinkCardModel card) async {
    try {
      await _getCollection().doc(card.id).update(card.toMap());
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteBlinkCard(String id) async {
    try {
      await _getCollection().doc(id).delete();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
