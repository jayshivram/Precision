class CurrencyInfo {
  final String code;
  final String name;
  final String flag;
  const CurrencyInfo(this.code, this.name, this.flag);
}

const List<CurrencyInfo> kCurrencies = [
  CurrencyInfo('USD', 'US Dollar', '🇺🇸'),
  CurrencyInfo('EUR', 'Euro', '🇪🇺'),
  CurrencyInfo('GBP', 'British Pound', '🇬🇧'),
  CurrencyInfo('JPY', 'Japanese Yen', '🇯🇵'),
  CurrencyInfo('CAD', 'Canadian Dollar', '🇨🇦'),
  CurrencyInfo('AUD', 'Australian Dollar', '🇦🇺'),
  CurrencyInfo('CHF', 'Swiss Franc', '🇨🇭'),
  CurrencyInfo('CNY', 'Chinese Yuan', '🇨🇳'),
  CurrencyInfo('INR', 'Indian Rupee', '🇮🇳'),
  CurrencyInfo('MXN', 'Mexican Peso', '🇲🇽'),
  CurrencyInfo('BRL', 'Brazilian Real', '🇧🇷'),
  CurrencyInfo('KRW', 'South Korean Won', '🇰🇷'),
  CurrencyInfo('SGD', 'Singapore Dollar', '🇸🇬'),
  CurrencyInfo('HKD', 'Hong Kong Dollar', '🇭🇰'),
  CurrencyInfo('NOK', 'Norwegian Krone', '🇳🇴'),
  CurrencyInfo('SEK', 'Swedish Krona', '🇸🇪'),
  CurrencyInfo('DKK', 'Danish Krone', '🇩🇰'),
  CurrencyInfo('NZD', 'New Zealand Dollar', '🇳🇿'),
  CurrencyInfo('ZAR', 'South African Rand', '🇿🇦'),
  CurrencyInfo('AED', 'UAE Dirham', '🇦🇪'),
  CurrencyInfo('SAR', 'Saudi Riyal', '🇸🇦'),
  CurrencyInfo('THB', 'Thai Baht', '🇹🇭'),
  CurrencyInfo('IDR', 'Indonesian Rupiah', '🇮🇩'),
  CurrencyInfo('MYR', 'Malaysian Ringgit', '🇲🇾'),
  CurrencyInfo('PHP', 'Philippine Peso', '🇵🇭'),
  CurrencyInfo('PKR', 'Pakistani Rupee', '🇵🇰'),
  CurrencyInfo('NGN', 'Nigerian Naira', '🇳🇬'),
  CurrencyInfo('EGP', 'Egyptian Pound', '🇪🇬'),
  CurrencyInfo('TRY', 'Turkish Lira', '🇹🇷'),
  CurrencyInfo('RUB', 'Russian Ruble', '🇷🇺'),
  CurrencyInfo('KES', 'Kenyan Shilling', '🇰🇪'),
  CurrencyInfo('TZS', 'Tanzanian Shilling', '🇹🇿'),
  CurrencyInfo('UGX', 'Ugandan Shilling', '🇺🇬'),
  CurrencyInfo('CDF', 'Congolese Franc', '🇨🇩'),
  CurrencyInfo('ZWL', 'Zimbabwean Dollar', '🇿🇼'),
  CurrencyInfo('ZMW', 'Zambian Kwacha', '🇿🇲'),
];

CurrencyInfo getCurrencyByCode(String code) {
  return kCurrencies.firstWhere(
    (c) => c.code == code,
    orElse: () => CurrencyInfo(code, code, '🏳️'),
  );
}
