import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/unit_conversion.dart';

class UnitConverterState {
  final String category;
  final String fromUnit;
  final String toUnit;
  final String fromValue;
  final String toValue;

  const UnitConverterState({
    this.category = 'Length',
    this.fromUnit = 'm',
    this.toUnit = 'km',
    this.fromValue = '',
    this.toValue = '',
  });

  UnitConverterState copyWith({
    String? category,
    String? fromUnit,
    String? toUnit,
    String? fromValue,
    String? toValue,
  }) {
    return UnitConverterState(
      category: category ?? this.category,
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      fromValue: fromValue ?? this.fromValue,
      toValue: toValue ?? this.toValue,
    );
  }
}

final unitConverterProvider =
    StateNotifierProvider<UnitConverterNotifier, UnitConverterState>((ref) {
  return UnitConverterNotifier();
});

const Map<String, List<String>> _defaultUnits = {
  'Length': ['m', 'km'],
  'Area': ['m²', 'km²'],
  'Volume': ['L', 'mL'],
  'Mass': ['kg', 'g'],
  'Temperature': ['°C', '°F'],
  'Speed': ['km/h', 'mph'],
  'Time': ['h', 'min'],
};

class UnitConverterNotifier extends StateNotifier<UnitConverterState> {
  UnitConverterNotifier() : super(const UnitConverterState());

  void setCategory(String category) {
    final defaults = _defaultUnits[category] ?? ['', ''];
    state = state.copyWith(
      category: category,
      fromUnit: defaults[0],
      toUnit: defaults[1],
      fromValue: '',
      toValue: '',
    );
    _convert();
  }

  void setFromUnit(String unit) {
    state = state.copyWith(fromUnit: unit);
    _convert();
  }

  void setToUnit(String unit) {
    state = state.copyWith(toUnit: unit);
    _convert();
  }

  void setFromValue(String value) {
    state = state.copyWith(fromValue: value);
    _convert();
  }

  void swap() {
    state = state.copyWith(
      fromUnit: state.toUnit,
      toUnit: state.fromUnit,
      fromValue: state.toValue,
    );
    _convert();
  }

  void _convert() {
    if (state.fromValue.isEmpty) {
      state = state.copyWith(toValue: '');
      return;
    }
    final val = double.tryParse(state.fromValue.replaceAll(',', ''));
    if (val == null) {
      state = state.copyWith(toValue: 'Invalid');
      return;
    }
    final result = UnitConversion.convert(
      val,
      state.fromUnit,
      state.toUnit,
      state.category,
    );

    String display;
    if (result == 0 && val != 0) {
      display = 'Error';
    } else if (result.abs() >= 1e10 || (result.abs() < 1e-6 && result != 0)) {
      display = result.toStringAsExponential(6);
    } else if (result == result.truncateToDouble()) {
      display = result.toInt().toString();
    } else {
      display = result.toStringAsFixed(10)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    state = state.copyWith(toValue: display);
  }
}
