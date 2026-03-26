import '../models/exchange_rates.dart';
import 'providers/i_exchange_rate_provider.dart';
import 'providers/mock_provider.dart';

class ExchangeRateService {
  IExchangeRateProvider _provider;
  ExchangeRates? _cache;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  ExchangeRateService(this._provider);

  /// Swap the live-rate API provider at runtime
  void setProvider(IExchangeRateProvider provider) {
    _provider = provider;
    _cache = null;
    _cacheTime = null;
  }

  Future<ExchangeRates> getRates(String base) async {
    final now = DateTime.now();
    if (_cache != null &&
        _cacheTime != null &&
        now.difference(_cacheTime!) < _cacheDuration &&
        _cache!.base.toUpperCase() == base.toUpperCase()) {
      return _cache!;
    }
    try {
      _cache = await _provider.getRates(base);
      _cacheTime = now;
      return _cache!;
    } catch (_) {
      if (_cache != null) return _cache!; // Return stale cache
      return MockProvider().getRates(base); // Absolute fallback
    }
  }

  void invalidateCache() {
    _cache = null;
    _cacheTime = null;
  }

  bool get hasCachedData => _cache != null;
  DateTime? get lastUpdated => _cacheTime;
}
