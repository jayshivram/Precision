class SettingsModel {
  final int decimalPrecision;
  final bool useScientificNotation;
  final bool useThousandsSeparator;
  final bool isRadianMode;
  final bool hapticFeedback;
  final int currencyRefreshMinutes;

  const SettingsModel({
    this.decimalPrecision = 6,
    this.useScientificNotation = false,
    this.useThousandsSeparator = true,
    this.isRadianMode = false,
    this.hapticFeedback = true,
    this.currencyRefreshMinutes = 5,
  });

  SettingsModel copyWith({
    int? decimalPrecision,
    bool? useScientificNotation,
    bool? useThousandsSeparator,
    bool? isRadianMode,
    bool? hapticFeedback,
    int? currencyRefreshMinutes,
  }) {
    return SettingsModel(
      decimalPrecision: decimalPrecision ?? this.decimalPrecision,
      useScientificNotation: useScientificNotation ?? this.useScientificNotation,
      useThousandsSeparator: useThousandsSeparator ?? this.useThousandsSeparator,
      isRadianMode: isRadianMode ?? this.isRadianMode,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      currencyRefreshMinutes: currencyRefreshMinutes ?? this.currencyRefreshMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
    'decimalPrecision': decimalPrecision,
    'useScientificNotation': useScientificNotation,
    'useThousandsSeparator': useThousandsSeparator,
    'isRadianMode': isRadianMode,
    'hapticFeedback': hapticFeedback,
    'currencyRefreshMinutes': currencyRefreshMinutes,
  };

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
    decimalPrecision: json['decimalPrecision'] as int? ?? 6,
    useScientificNotation: json['useScientificNotation'] as bool? ?? false,
    useThousandsSeparator: json['useThousandsSeparator'] as bool? ?? true,
    isRadianMode: json['isRadianMode'] as bool? ?? false,
    hapticFeedback: json['hapticFeedback'] as bool? ?? true,
    currencyRefreshMinutes: json['currencyRefreshMinutes'] as int? ?? 5,
  );
}
