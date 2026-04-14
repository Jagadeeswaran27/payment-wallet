import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthResult {
  const PhoneAuthResult();
}

class CodeSent extends PhoneAuthResult {
  final String verificationId;
  final int? resendToken;
  const CodeSent(this.verificationId, this.resendToken);
}

class PhoneAuthError extends PhoneAuthResult {
  final String message;
  const PhoneAuthError(this.message);
}

class PhoneAuthCompleted extends PhoneAuthResult {
  final PhoneAuthCredential credential;
  const PhoneAuthCompleted(this.credential);
}
