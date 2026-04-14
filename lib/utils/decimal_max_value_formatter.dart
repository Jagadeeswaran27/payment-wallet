import 'package:flutter/services.dart';

class DecimalMaxValueFormatter extends TextInputFormatter {
  final double maxValue;
  final int decimalPlaces;

  DecimalMaxValueFormatter({required this.maxValue, this.decimalPlaces = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Allow "." at the start, treat as "0."
    if (newValue.text == '.') {
      return newValue;
    }

    // Regex to match up to N decimal places
    final regExp = RegExp(r'^\d*\.?\d{0,' + decimalPlaces.toString() + r'}$');
    if (!regExp.hasMatch(newValue.text)) {
      return oldValue;
    }

    // Check max value
    try {
      final value = double.parse(newValue.text);
      if (value <= maxValue) {
        return newValue;
      }
    } catch (_) {}

    return oldValue;
  }
}
