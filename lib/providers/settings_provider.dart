import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(const SettingsModel()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('settings');
    if (json != null) {
      state = SettingsModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', jsonEncode(state.toJson()));
  }

  void setDecimalPrecision(int v) {
    state = state.copyWith(decimalPrecision: v);
    _save();
  }

  void toggleScientificNotation() {
    state = state.copyWith(useScientificNotation: !state.useScientificNotation);
    _save();
  }

  void toggleThousandsSeparator() {
    state = state.copyWith(useThousandsSeparator: !state.useThousandsSeparator);
    _save();
  }

  void toggleRadianMode() {
    state = state.copyWith(isRadianMode: !state.isRadianMode);
    _save();
  }

  void setRadianMode(bool v) {
    state = state.copyWith(isRadianMode: v);
    _save();
  }

  void toggleHapticFeedback() {
    state = state.copyWith(hapticFeedback: !state.hapticFeedback);
    _save();
  }

  void setCurrencyRefreshMinutes(int v) {
    state = state.copyWith(currencyRefreshMinutes: v);
    _save();
  }
}
