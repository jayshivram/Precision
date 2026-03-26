import '../constants/units.dart';

class UnitConversion {
  static double convert(double value, String fromUnit, String toUnit, String category) {
    if (category == 'Temperature') {
      return _convertTemperature(value, fromUnit, toUnit);
    }

    final factors = kUnitFactors[category];
    if (factors == null) return 0;

    final fromFactor = factors[fromUnit];
    final toFactor = factors[toUnit];
    if (fromFactor == null || toFactor == null || toFactor == 0) return 0;

    return value * fromFactor / toFactor;
  }

  static double _convertTemperature(double val, String from, String to) {
    if (from == to) return val;

    // Convert to Celsius first
    double celsius;
    switch (from) {
      case '°C':
        celsius = val;
        break;
      case '°F':
        celsius = (val - 32) * 5 / 9;
        break;
      case 'K':
        celsius = val - 273.15;
        break;
      default:
        celsius = val;
    }

    // Convert from Celsius to target
    switch (to) {
      case '°C':
        return celsius;
      case '°F':
        return celsius * 9 / 5 + 32;
      case 'K':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }
}
