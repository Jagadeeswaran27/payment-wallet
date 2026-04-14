import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/core/services/firebase_storage_service.dart';

final firebaseStorageServiceProvider = Provider<FirebaseStorageService>(
  (ref) => FirebaseStorageService.instance,
);
