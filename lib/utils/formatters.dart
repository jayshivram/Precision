import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/settings_model.dart';

class PrecisionFormatter {
  static String formatResult(double value, SettingsModel settings) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';

    if (settings.useScientificNotation && value.abs() >= 1e10) {
      return value.toStringAsExponential(settings.decimalPrecision);
    }

    // Check if the value is an integer
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      if (settings.useThousandsSeparator) {
        return NumberFormat('#,##0').format(value.toInt());
      }
      return value.toInt().toString();
    }

    // Format with appropriate decimal places
    String result;
    if (settings.useThousandsSeparator) {
      String pattern = '#,##0.${'#' * settings.decimalPrecision}';
      result = NumberFormat(pattern).format(value);
    } else {
      result = value.toStringAsFixed(settings.decimalPrecision);
      // Remove trailing zeros
      if (result.contains('.')) {
        result = result.replaceAll(RegExp(r'0+$'), '');
        result = result.replaceAll(RegExp(r'\.$'), '');
      }
    }

    return result;
  }

  static String formatCurrency(double value) {
    if (value == value.truncateToDouble() && value.abs() < 1e12) {
      return NumberFormat('#,##0').format(value.toInt());
    }
    return NumberFormat('#,##0.00').format(value);
  }

  static String formatConversion(double value) {
    if (value == 0) return '0';
    if (value.abs() >= 1e10 || (value.abs() < 1e-6 && value != 0)) {
      return value.toStringAsExponential(6);
    }
    if (value == value.truncateToDouble()) {
      return NumberFormat('#,##0').format(value.toInt());
    }
    String result = value.toStringAsFixed(10);
    result = result.replaceAll(RegExp(r'0+$'), '');
    result = result.replaceAll(RegExp(r'\.$'), '');
    return result;
  }
}

class ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    // Allow only digits, a single decimal point, and a leading minus
    final clean = text.replaceAll(',', '');
    if (clean.isEmpty) return newValue;

    // Validate number shape
    if (!RegExp(r'^-?\d*\.?\d*$').hasMatch(clean)) return oldValue;

    final parts = clean.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : (text.endsWith('.') ? '.' : '');

    // Format integer part with commas
    String formatted;
    if (intPart.isEmpty || intPart == '-') {
      formatted = intPart;
    } else {
      final isNeg = intPart.startsWith('-');
      final digits = isNeg ? intPart.substring(1) : intPart;
      final buf = StringBuffer();
      for (var i = 0; i < digits.length; i++) {
        if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
        buf.write(digits[i]);
      }
      formatted = isNeg ? '-${buf.toString()}' : buf.toString();
    }
    formatted += decPart;

    // Preserve cursor position relative to digits
    final oldDigits = oldValue.text.substring(0, oldValue.selection.baseOffset).replaceAll(',', '').length;
    var newOffset = 0;
    var digitsSeen = 0;
    for (var i = 0; i < formatted.length && digitsSeen < oldDigits + (newValue.text.replaceAll(',', '').length - oldValue.text.replaceAll(',', '').length); i++) {
      newOffset = i + 1;
      if (formatted[i] != ',') digitsSeen++;
    }
    newOffset = newOffset.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
