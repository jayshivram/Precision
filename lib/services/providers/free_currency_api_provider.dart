import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/api_keys.dart';
import '../../models/exchange_rates.dart';
import 'i_exchange_rate_provider.dart';
import 'i_historical_rate_provider.dart';

class FreeCurrencyApiProvider
    implements IExchangeRateProvider, IHistoricalRateProvider {
  static const String _baseUrl = 'https://api.freecurrencyapi.com/v1';
  final String _apiKey;

  FreeCurrencyApiProvider({String apiKey = kFreeCurrencyApiKey})
      : _apiKey = apiKey;

  @override
  Future<ExchangeRates> getRates(String base) async {
    final uri = Uri.parse(
      '$_baseUrl/latest?apikey=$_apiKey&base_currency=${base.toUpperCase()}',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 429) throw Exception('Rate limit exceeded');
    if (response.statusCode != 200) {
      throw Exception('FreeCurrencyAPI fetch failed: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final rawRates = json['data'] as Map<String, dynamic>;

    return ExchangeRates(
      base: base.toUpperCase(),
      timestamp: DateTime.now(),
      rates: rawRates.map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

  @override
  Future<Map<String, double>> getHistoricalRates(
      String base, String date) async {
    final uri = Uri.parse(
      '$_baseUrl/historical?apikey=$_apiKey'
      '&base_currency=${base.toUpperCase()}&date=$date',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 429) throw Exception('Rate limit exceeded');
    if (response.statusCode != 200) {
      throw Exception('Historical fetch failed: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    final dayData = data[date] as Map<String, dynamic>?;
    if (dayData == null) throw Exception('No data for $date');

    return dayData.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }
}
