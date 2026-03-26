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
