import 'package:app/models/user_model.dart';

class PhoneAuthState {
  final String? phoneNumber;
  final String? verificationId;
  final int? resendToken;
  final UserModel? user;

  const PhoneAuthState({
    this.phoneNumber,
    this.verificationId,
    this.resendToken,
    this.user,
  });

  PhoneAuthState copyWith({
    String? phoneNumber,
    String? verificationId,
    int? resendToken,
    UserModel? user,
  }) {
    return PhoneAuthState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      user: user ?? this.user,
    );
  }
}
