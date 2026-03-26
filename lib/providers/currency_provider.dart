import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exchange_rates.dart';
import '../services/exchange_rate_service.dart';
import '../services/historical_rate_service.dart';
import '../services/providers/haxqer_provider.dart';
import '../services/providers/frankfurter_provider.dart';

// Live rate service
final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  return ExchangeRateService(HaxqerProvider());
});

// Historical rate service
final historicalRateServiceProvider = Provider<HistoricalRateService>((ref) {
  return HistoricalRateService(FrankfurterProvider());
});

// Currency converter state
class CurrencyState {
  final String fromCurrency;
  final String toCurrency;
  final String amount;
  final ExchangeRates? rates;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const CurrencyState({
    this.fromCurrency = 'USD',
    this.toCurrency = 'EUR',
    this.amount = '0',
    this.rates,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  CurrencyState copyWith({
    String? fromCurrency,
    String? toCurrency,
    String? amount,
    ExchangeRates? rates,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return CurrencyState(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
      rates: rates ?? this.rates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  double get convertedAmount {
    if (rates == null || amount.isEmpty) return 0;
    final val = double.tryParse(amount.replaceAll(',', '')) ?? 0;
    return rates!.convert(val, fromCurrency, toCurrency);
  }

  double get exchangeRate {
    if (rates == null) return 0;
    return rates!.convert(1, fromCurrency, toCurrency);
  }
}

final currencyProvider =
    StateNotifierProvider<CurrencyNotifier, CurrencyState>((ref) {
  final service = ref.watch(exchangeRateServiceProvider);
  return CurrencyNotifier(service);
});

class CurrencyNotifier extends StateNotifier<CurrencyState> {
  final ExchangeRateService _service;

  CurrencyNotifier(this._service) : super(const CurrencyState()) {
    fetchRates();
  }

  Future<void> fetchRates() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final rates = await _service.getRates(state.fromCurrency);
      state = state.copyWith(
        rates: rates,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFromCurrency(String code) {
    state = state.copyWith(fromCurrency: code);
    fetchRates();
  }

  void setToCurrency(String code) {
    state = state.copyWith(toCurrency: code);
  }

  void setAmount(String amount) {
    state = state.copyWith(amount: amount);
  }

  void inputDigit(String digit) {
    if (state.amount == '0' && digit != '.') {
      state = state.copyWith(amount: digit);
    } else {
      state = state.copyWith(amount: state.amount + digit);
    }
  }

  void inputDecimal() {
    if (state.amount.contains('.')) return;
    state = state.copyWith(amount: '${state.amount}.');
  }

  void deleteDigit() {
    if (state.amount.length <= 1) {
      state = state.copyWith(amount: '0');
      return;
    }
    state = state.copyWith(
      amount: state.amount.substring(0, state.amount.length - 1),
    );
  }

  void swap() {
    state = state.copyWith(
      fromCurrency: state.toCurrency,
      toCurrency: state.fromCurrency,
    );
    fetchRates();
  }

  void refreshRates() {
    _service.invalidateCache();
    fetchRates();
  }
}

// Historical rate lookup
class HistoricalRateQuery {
  final String from;
  final String to;
  final DateTime date;
  const HistoricalRateQuery({
    required this.from,
    required this.to,
    required this.date,
  });
}

final historicalRateFutureProvider =
    FutureProvider.family<double?, HistoricalRateQuery>((ref, query) {
  final service = ref.watch(historicalRateServiceProvider);
  return service.getRate(from: query.from, to: query.to, date: query.date);
});
