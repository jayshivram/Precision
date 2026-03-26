class ExchangeRates {
  final String base;
  final DateTime timestamp;
  final Map<String, double> rates;

  ExchangeRates({
    required this.base,
    required this.timestamp,
    required this.rates,
  });

  double? getRate(String currency) => rates[currency.toUpperCase()];

  double convert(double amount, String from, String to) {
    if (from.toUpperCase() == base.toUpperCase()) {
      return amount * (rates[to.toUpperCase()] ?? 0);
    }
    final fromRate = rates[from.toUpperCase()];
    final toRate = rates[to.toUpperCase()];
    if (fromRate == null || toRate == null || fromRate == 0) return 0;
    return amount * (toRate / fromRate);
  }
}
