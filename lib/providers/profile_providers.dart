import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/controllers/profile_controller.dart';
import 'package:app/core/services/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService.instance,
);

final profileControllerProvider =
    AsyncNotifierProvider.autoDispose<ProfileController, void>(
      ProfileController.new,
    );
