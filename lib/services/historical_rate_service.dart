import 'providers/i_historical_rate_provider.dart';

class HistoricalRateService {
  final IHistoricalRateProvider _provider;

  HistoricalRateService(this._provider);

  Future<double?> getRate({
    required String from,
    required String to,
    required DateTime date,
  }) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      final rates = await _provider.getHistoricalRates(from, dateStr);
      return rates[to.toUpperCase()];
    } catch (_) {
      return null;
    }
  }
}
