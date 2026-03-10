import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  FirebaseStorageService._();

  static final FirebaseStorageService instance = FirebaseStorageService._();

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImage(File image) async {
    final uid = _auth.currentUser!.uid;

    final String fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final Reference ref = _firebaseStorage.ref().child(
      'profiles/$uid/$fileName',
    );

    final UploadTask uploadTask = ref.putFile(
      File(image.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );

    await uploadTask;

    return ref.fullPath;
  }

  Future<void> uploadKycImage(File image) async {
    final uid = _auth.currentUser!.uid;

    final String fileName = 'kyc_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final Reference ref = _firebaseStorage.ref().child('kyc/$uid/$fileName');

    final UploadTask uploadTask = ref.putFile(
      File(image.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    await uploadTask;
  }

  Future<String> getImageUrlFromPath(String path) async {
    final Reference ref = _firebaseStorage.ref(path);
    return await ref.getDownloadURL();
  }
}
