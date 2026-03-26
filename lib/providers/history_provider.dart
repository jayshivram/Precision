import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_entry.dart';

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryEntry>>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  static const int _maxEntries = 50;
  static const String _key = 'calc_history';

  HistoryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      final list = (jsonDecode(json) as List)
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  void addEntry(String expression, String result, String tab) {
    final entry = HistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      expression: expression,
      result: result,
      tab: tab,
      timestamp: DateTime.now(),
    );
    state = [entry, ...state];
    if (state.length > _maxEntries) {
      state = state.sublist(0, _maxEntries);
    }
    _save();
  }

  void removeEntry(String id) {
    state = state.where((e) => e.id != id).toList();
    _save();
  }

  void clearAll() {
    state = [];
    _save();
  }
}
