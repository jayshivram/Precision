import '../../models/exchange_rates.dart';
import 'i_exchange_rate_provider.dart';

class MockProvider implements IExchangeRateProvider {
  @override
  Future<ExchangeRates> getRates(String base) async {
    return ExchangeRates(
      base: 'USD',
      timestamp: DateTime.now(),
      rates: {
        'USD': 1.0, 'EUR': 0.924, 'GBP': 0.770, 'JPY': 150.86,
        'CAD': 1.383, 'AUD': 1.496, 'CHF': 0.866, 'CNY': 7.121,
        'INR': 84.08, 'MXN': 19.93, 'BRL': 5.695, 'KRW': 1378.97,
        'SGD': 1.316, 'HKD': 7.773, 'NOK': 10.931, 'SEK': 10.542,
        'DKK': 6.894, 'NZD': 1.652, 'ZAR': 17.588, 'AED': 3.673,
        'SAR': 3.756, 'THB': 33.48, 'IDR': 15569.3, 'MYR': 4.328,
        'PHP': 57.83, 'PKR': 277.73, 'NGN': 1643.34, 'EGP': 48.67,
        'TRY': 34.25, 'RUB': 96.55, 'KES': 129.01, 'TZS': 2725.28,
        'UGX': 3665.69, 'CDF': 2841.02, 'ZWL': 322.0, 'ZMW': 26.58,
      },
    );
  }
}
