import '../../models/exchange_rates.dart';

abstract class IExchangeRateProvider {
  Future<ExchangeRates> getRates(String base);
}
