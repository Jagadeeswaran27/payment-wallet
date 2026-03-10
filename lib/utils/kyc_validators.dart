import 'package:intl/intl.dart';

class KycValidators {
  static String? validateAadhar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Aadhaar number';
    }
    if (value.length != 12) {
      return 'Aadhaar card must be 12 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Aadhaar card must contain only digits';
    }
    return null;
  }

  static String? validatePanCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter PAN card number';
    }
    if (value.length != 10) {
      return 'PAN card must be 10 characters';
    }
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value.toUpperCase())) {
      return 'Invalid PAN card format';
    }
    return null;
  }

  static String? validateAge(String? dobString) {
    if (dobString == null || dobString.isEmpty) {
      return 'Please select Date of Birth';
    }

    try {
      final dob = DateFormat('dd/MM/yyyy').parse(dobString);
      final now = DateTime.now();

      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }

      if (age < 18) {
        return 'You must be at least 18 years old';
      }
    } catch (e) {
      return 'Invalid date format';
    }
    return null;
  }
}
