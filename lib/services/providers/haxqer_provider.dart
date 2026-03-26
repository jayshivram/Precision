import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/exchange_rates.dart';
import 'i_exchange_rate_provider.dart';

class HaxqerProvider implements IExchangeRateProvider {
  static const String _endpoint = 'https://api.exchangerate.fun/latest';

  @override
  Future<ExchangeRates> getRates(String base) async {
    final uri = Uri.parse('$_endpoint?base=${base.toUpperCase()}');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Rate fetch failed: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final rawRates = json['rates'] as Map<String, dynamic>;

    return ExchangeRates(
      base: json['base'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        ((json['timestamp'] as num?)?.toInt() ?? 0) * 1000,
      ),
      rates: rawRates.map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
    );
  }
}
