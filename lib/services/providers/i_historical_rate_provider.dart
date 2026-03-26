abstract class IHistoricalRateProvider {
  /// Returns rates for a single past [date] relative to [base].
  /// Date format: YYYY-MM-DD
  Future<Map<String, double>> getHistoricalRates(String base, String date);
}
