import 'dart:convert';
import 'package:http/http.dart' as http;
import 'i_historical_rate_provider.dart';

class FrankfurterProvider implements IHistoricalRateProvider {
  static const String _baseUrl = 'https://api.frankfurter.dev/v2';

  @override
  Future<Map<String, double>> getHistoricalRates(
      String base, String date) async {
    final uri = Uri.parse(
      '$_baseUrl/rates?date=$date&base=${base.toUpperCase()}',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Frankfurter fetch failed: ${response.statusCode}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    final rates = <String, double>{};
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final quote = map['quote'] as String;
      final rate = (map['rate'] as num).toDouble();
      rates[quote] = rate;
    }
    // Include the base currency itself for same-currency lookups
    rates[base.toUpperCase()] = 1.0;
    return rates;
  }
}
